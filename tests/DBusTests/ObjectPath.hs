-- Copyright (C) 2010-2012 John Millikin <john@john-millikin.com>
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

module DBusTests.ObjectPath (test_ObjectPath) where

import Data.List (intercalate)
import Test.QuickCheck
import Test.Tasty
import Test.Tasty.HUnit
import Test.Tasty.QuickCheck

import DBus

test_ObjectPath :: TestTree
test_ObjectPath = testGroup "ObjectPath"
    [ test_Parse
    , test_ParseInvalid
    ]

test_Parse :: TestTree
test_Parse = testProperty "parse" prop where
    prop = forAll gen_ObjectPath check
    check x = case parseObjectPath x of
        Nothing -> False
        Just parsed -> formatObjectPath parsed == x

test_ParseInvalid :: TestTree
test_ParseInvalid = testCase "parse-invalid" $ do
    -- empty
    Nothing @=? parseObjectPath ""

    -- bad char
    Nothing @=? parseObjectPath "/f!oo"

    -- ends with a slash
    Nothing @=? parseObjectPath "/foo/"

    -- empty element
    Nothing @=? parseObjectPath "/foo//bar"

    -- trailing chars
    Nothing @=? parseObjectPath "/foo!"

gen_ObjectPath :: Gen String
gen_ObjectPath = gen where
    chars = ['a'..'z'] ++ ['A'..'Z'] ++ ['0'..'9'] ++ "_"

    gen = do
        xs <- listOf (listOf1 (elements chars))
        return ("/" ++ intercalate "/" xs)

instance Arbitrary ObjectPath where
    arbitrary = fmap objectPath_ gen_ObjectPath
