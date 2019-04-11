# buildScriptBuilder

## Usage
Run the executable from the directory for a particular JIRA ticket, e.g. DOTFREE-1250. This directory should contain all of the modified PL/SQL objects, e.g. package specs/bodies, triggers, views, etc., as well as any other SQL scripts needed.

The files that will be included are those with the following extensions (in this order): sql, vw, tps, tpb, trg, fnc, prc, pks, pkb.

## Result
After running the executable, a "BuildScript.sql" file is created/over-written that can be executed, e.g. in Oracle SQL Developer, to run all of the scripts in a row.