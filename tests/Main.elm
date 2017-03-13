port module Main exposing (..)

import Test exposing (..)
import Test.Runner.Node exposing (run, TestProgram)
import Json.Encode exposing (Value)
import Table.RowFilterTest
import Table.UpdateTest


allTests : Test
allTests =
    describe "all tests"
        [ Table.RowFilterTest.all
        , Table.UpdateTest.all
        ]


main : TestProgram
main =
    run emit allTests


port emit : ( String, Value ) -> Cmd msg
