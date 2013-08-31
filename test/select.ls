should = (require \chai).should!
{mk-pgrest-fortest} = require \./testlib

var _plx, plx
describe 'Select', ->
  this.timeout 10000ms
  beforeEach (done) ->
    _plx <- mk-pgrest-fortest!
    plx := _plx
    <- plx.query """
    DROP TABLE IF EXISTS pgrest_test;
    CREATE TABLE pgrest_test (
        field text not null primary key,
        value text[] not null,
        last_update timestamp
    );
    INSERT INTO pgrest_test (field, value, last_update) values('a', '{0.0.1}', NOW());
    INSERT INTO pgrest_test (field, value, last_update) values('b', '{0.0.2}', NOW());
    INSERT INTO pgrest_test (field, value, last_update) values('c', '{0.0.3}', NOW());
    INSERT INTO pgrest_test (field, value, last_update) values('d', '{0.0.4}', NOW());
    INSERT INTO pgrest_test (field, value, last_update) values('e', '{0.0.4}', NOW());
    """
    done!
  afterEach (done) ->
    <- plx.query "DROP TABLE IF EXISTS pgrest_test;"
    done!
  describe 'is excepted to return a self-descriptive result', -> ``it``
    .. 'should contain operation name, paging info.', (done) ->
      res <- plx.query """select pgrest_select($1)""", [collection: \pgrest_test]
      res.0.should.have.keys 'pgrest_select'
      res.0.pgrest_select.paging.count.should.eql 5
      res.0.pgrest_select.paging.l.should.eql 30
      res.0.pgrest_select.paging.sk.should.eql 0
      done!
  describe 'table/view(s) with other conditoin', -> ``it``
    .. 'should return only matched subset when coulum name and value is given in the condition.', (done) ->
      q = [collection: \pgrest_test, q: {field:'a'}]
      [pgrest_select:res] <- plx.query """select pgrest_select($1)""", q
      res.paging.count.should.eq 1
      res.entries.0.field.should.eq 'a'
      res.entries.0.value.0.should.eq '0.0.1'

      q = [collection: \pgrest_test, q: {value:'{0.0.4}'}]
      [pgrest_select:res] <- plx.query """select pgrest_select($1)""", q
      res.paging.count.should.eq 2
      done!
    .. 'should return limited subset when paging is given in the condition.', (done) ->
      [pgrest_select:res] <- plx.query """select pgrest_select($1)""", [collection: \pgrest_test, l:'1']
      res.paging.count.should.eq 5
      res.paging.l.should.eq 1
      res.paging.sk.should.eq 0
      done!
