should = (require \chai).should!
expect = (require \chai).expect
{mk-pgrest-fortest} = require \./testlib

require! <[supertest express]>

var plx, app
pgrest = require \..
boot = {}

describe 'Routing', ->
  this.timeout 10000ms
  beforeEach (done) ->
    _plx <- mk-pgrest-fortest!
    plx := _plx
    <- plx.query """
    DROP TABLE IF EXISTS issue;
    DROP TABLE IF EXISTS nonexist_table;
    DROP TABLE IF EXISTS initiative;
    CREATE TABLE issue (
        id int not null primary key,
        title text not null,
        last_update timestamp
    );
    CREATE TABLE initiative (
        id int not null primary key,
        issue_id int not null,
        title text not null,
        last_update timestamp
    );
    INSERT INTO issue (id, title, last_update) values(1, 'test', NOW());
    INSERT INTO initiative (id, issue_id, title, last_update) values(1, 1, 'test 1', NOW());
    INSERT INTO initiative (id, issue_id, title, last_update) values(2, 2, 'test 2', NOW());
    """
    done!
  afterEach (done) ->
    <- plx.query """
      DROP TABLE IF EXISTS issue;
      DROP TABLE IF EXISTS nonexist_table;
      DROP TABLE IF EXISTS initiative;
    """
    done!
  describe 'with public schema', ->
    beforeEach (done) ->
      {mount-default,with-prefix} = pgrest.routes!
      app := express!
      app.use express.cookieParser!
      app.use express.json!
      cols <- mount-default plx, null, with-prefix '/collections', -> app.all.apply app, &
      done!
    describe 'GET /', -> ``it``
      .. 'should list valide endpoints', (done) ->
        (err, res) <- supertest app
          .get '/'
          .expect 'Content-Type' /json/
          .expect 200
          .end
        res.body.length.should.eq 2
        res.body.should.deep.eq [ 'collections', 'runCommand' ]
        done!
    describe.skip 'POST /', -> ``it``
      .. 'should return error', (done) ->
        #FIXME: TBD
        done!
    describe.skip 'PUT /', -> ``it``
      .. 'should return error', (done) ->
        #FIXME: TBD
        done!
    describe.skip 'DELETE /', -> ``it``
      .. 'should return error', (done) ->
        #FIXME: TBD
        done!
    describe 'GET /collections', -> ``it``
      .. 'should list all table or view names', (done) ->
        (err, res) <- supertest app
          .get '/collections'
          .expect 'Content-Type' /json/
          .expect 200
          .end
        res.body.length.should.eq 2
        done!
    describe.skip 'POST /collections', -> ``it``
      .. 'should return error', (done) ->
        #FIXME: TBD
        done!
    describe.skip 'PUT /collections', -> ``it``
      .. 'should return error', (done) ->
        #FIXME: TBD
        done!
    describe.skip 'DELETE /collections', -> ``it``
      .. 'should return error', (done) ->
        #FIXME: TBD
        done!
    describe 'GET /collections/$collection_name', -> ``it``
      .. 'should list all content of a corresponding table or view without query', (done) ->
        (err, res) <- supertest app
          .get '/collections/issue'
          .expect 'Content-Type' /json/
          .expect 200
          .end
        res.body.paging.count.should.eq 1
        res.body.paging.l.should.eq 30
        res.body.paging.sk.should.eq 0
        res.body.entries.0.title.should.eq \test
        done!
    describe 'POST /collections/$collection_name', -> ``it``
      .. 'should create primary key automatically if x-pgrest-create-idenity-key in the header', (done) ->
        err, res <- supertest app
          .post '/collections/nonexist_table'
          .send [{username: \u1}, {username: \u2}]
          .set 'Accept', 'application/json'
          .set 'x-pgrest-create-identity-key', 'yes'
          .end
        res.text.should.equal '[1,1]'
        cols <- plx.query "SELECT * FROM nonexist_table"
        cols.map ->
          it.should.have.property \_id
        done!
    describe.skip 'PUT /collections/$collection_name', -> ``it``
      .. 'should update a row in corresponding table', (done) ->
        done!
    describe.skip 'DELETE /collections/$collection_name', -> ``it``
      .. 'should delete a row in corresponding table', (done) ->
        done!
  describe 'with custom schema', ->
    beforeEach (done) ->
      {mount-default,with-prefix} = pgrest.routes!
      app := express!
      app.use express.cookieParser!
      app.use express.json!
      cols <- mount-default plx, 'custom', with-prefix '/collections', -> app.all.apply app, &
      done!
    describe 'GET /collections',  -> ``it``
      .. 'should return empty when not table or view with custom schema', (done) ->
        (err, res) <- supertest app
          .get '/collections'
          .expect 'Content-Type' /json/
          .expect 200
          .end
        res.body.should.deep.eq []
        done!
