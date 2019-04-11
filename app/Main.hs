import System.IO (hClose, hPutStrLn, openTempFile)
import System.Directory (getDirectoryContents, renameFile)
import Data.List (filter, sort)
import Data.Char (toLower)

-- Throws an error if searchTerm is longer than string
endsWith :: String -> String -> Bool
endsWith [] _ = False
endsWith _ [] = False
endsWith string searchTerm = searchTerm == drop (length string - length searchTerm) (map toLower string)

main :: IO ()
main = do
    (tempName, tempHandle) <- openTempFile "." "temp"

    let preamble = ["set term on",
                    "set echo off",
                    "set define off",
                    "whenever sqlerror exit failure rollback;",
                    "whenever oserror exit failure rollback;",
                    "spool \"DEPLOYMENT_LOG.TXT\"",
                    "-------"]
    mapM_ (hPutStrLn tempHandle) preamble
    contents <- getDirectoryContents "."
    let sortedContents = sort contents
        scripts = filter (\file -> (file /= "BuildScript.sql") && (file `endsWith` ".sql")) sortedContents
        views = filter (\file -> file `endsWith` ".vw") sortedContents
        typeSpecs = filter (\file -> file `endsWith` ".tps") sortedContents
        typeBodies = filter (\file -> file `endsWith` ".tpb") sortedContents
        triggers = filter (\file -> file `endsWith` ".trg") sortedContents
        functions = filter (\file -> file `endsWith` ".fnc") sortedContents
        procedures = filter (\file -> file `endsWith` ".prc") sortedContents
        specs  = filter (\file -> file `endsWith` ".pks") sortedContents
        bodies = filter (\file -> file `endsWith` ".pkb") sortedContents
        buildScriptLines file = "prompt \"" ++ file ++ "\"\n@" ++ file ++ ";\nshow errors\n--"
        buildScriptOrder = scripts ++ views ++ typeSpecs ++ typeBodies ++ triggers ++ functions ++ procedures ++ specs ++ bodies
        buildLines = map (buildScriptLines) buildScriptOrder
    mapM_ (hPutStrLn tempHandle) buildLines
    hPutStrLn tempHandle "\ncommit;\n"
    hClose tempHandle
    renameFile tempName "BuildScript.sql"