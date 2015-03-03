--- Some [Gray code](http://en.wikipedia.org/wiki/Gray_code) utilities.

--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--
-- [ MIT license: http://www.opensource.org/licenses/mit-license.php ]
--

-- Standard library imports --
local frexp = math.frexp

-- Modules --
local operators = require("bitwise_ops.operators")

-- Imports --
local band = operators.band
local bor = operators.bor
local bxor = operators.bxor
local rshift = operators.rshift

-- Cached module references --
local _BinaryToGray_
local _GrayToBinary_

-- Exports --
local M = {}

--- Converts an unsigned integer (binary) to a Gray code.
--
-- This is an inverse of @{GrayToBinary}.
-- @uint n Binary value, &ge; 0.
-- @treturn uint Gray code.
function M.BinaryToGray (n)
	return bxor(rshift(n, 1), n)
end

-- Helper to iterate Gray codes
local function AuxFirstN (n, prev)
	if prev then
		local index = _GrayToBinary_(prev) + 1

		if index <= n then
			return _BinaryToGray_(index), index
		end
	else
		return 0, 0
	end
end

--
local function FirstNBody (n, prev, iter)
	n = (n or 2^32) - 1

	if prev then
		n = _GrayToBinary_(prev) + n + 1
	end

	return iter, n, prev or false	
end

--- Iterates over a series of Gray codes.
-- @uint[opt=2^32] n Number of iterations.
-- @uint[opt] prev If present, iteration starts at the next Gray code, i.e. at `Next(prev)`.
-- If absent, it begins at 0.
-- @treturn iterator Supplies the following, in order, at each iteration:
--
-- * Gray code.
-- * Binary value, i.e. `GrayToBinary(gray)`.
function M.FirstN (n, prev)
	return FirstNBody(n, prev, AuxFirstN, false)
end

--
local function Change (index, prev)
	local gray = _BinaryToGray_(index)
	local diff = gray - prev
	local added = diff > 0
	local _, exp = frexp(added and diff or -diff)

	return gray, exp, added
end

--
local function AuxFirstN_Change (n, prev)
	local index = _GrayToBinary_(prev) + 1

	if index <= n then
		return Change(index, prev)
	end
end

--- DOCME
function M.FirstN_Change (n, prev)
	return FirstNBody(n, prev or 0, AuxFirstN_Change)
end

--- Converts a Gray code to an unsigned inte
--
-- This is an inverse of @{BinaryToGray}.
-- @uint gray Gray code.
-- @treturn uint Binary value.
function M.GrayToBinary (gray)
	gray = bxor(gray, rshift(gray, 16))
	gray = bxor(gray, rshift(gray, 8))
	gray = bxor(gray, rshift(gray, 4))
	gray = bxor(gray, rshift(gray, 2))

	return bxor(gray, rshift(gray, 1))
end

--- Successor.
-- @uint gray Gray code.
-- @treturn uint Next Gray code, i.e. `BinaryToGray(GrayToBinary(gray) + 1)`.
function M.Next (gray)
	return _BinaryToGray_(_GrayToBinary_(gray) + 1)
end

--- DOCME
function M.Next_Change (gray)
	return Change(_GrayToBinary_(gray) + 1)
end

-- Cache module members.
_BinaryToGray_ = M.BinaryToGray
_GrayToBinary_ = M.GrayToBinary

-- Export the module.
return M