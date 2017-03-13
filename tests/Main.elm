port module Main exposing (..)

import Test exposing (..)
import Test.Runner.Node exposing (run, TestProgram)
import Json.Encode exposing (Value)
import InputTable.RowFilterTest
import InputTable.UpdateTest


allTests : Test
allTests =
    describe "all tests"
        [ InputTable.RowFilterTest.all
        , InputTable.UpdateTest.all
        ]


main : TestProgram
main =
    run emit allTests


port emit : ( String, Value ) -> Cmd msg
