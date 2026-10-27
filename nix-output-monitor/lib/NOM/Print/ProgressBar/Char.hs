module NOM.Print.ProgressBar.Char (word5ToWord8, progressByteToBrailleChar) where

import Data.Bits (bit, testBit, (.|.))
import Relude

-- >>> word5ToWord8 31
-- 255
word5ToWord8 :: Word8 -> Word8
word5ToWord8 n
  | n < 16 = n * 16
  | otherwise = (n - 16) + 255 - 15

{- | Translate a "progress byte" which is a number x ∈ [0..255] to a Unicode Braille character
so that we count in binary using the eight Braille dots from the bottom right to the top left.

Full block:
>>> progressByteToBrailleChar 255
'\10495'

Empty block:
>>> progressByteToBrailleChar 0
'\10240'

Some block in between
>>> progressByteToBrailleChar 110
'\10302'
-}
progressByteToBrailleChar :: Word8 -> Char
progressByteToBrailleChar num = chr $ emptyBrailleChar + fromIntegral (permuteProgressByteBitsToBrailleOffset num)

-- | Base point to add offsets to to get Braille characters.
emptyBrailleChar :: Int
emptyBrailleChar = 0x2800

-- | Permutes the bits of a "progress byte" into a Braille character Unicode offset.
permuteProgressByteBitsToBrailleOffset :: Word8 -> Word8
permuteProgressByteBitsToBrailleOffset x =
  -- The permutation has been derived on leanas white board.
  wireBits 0 7 x
    .|. wireBits 1 5 x
    .|. wireBits 2 4 x
    .|. wireBits 3 3 x
    .|. wireBits 4 6 x
    .|. wireBits 5 2 x
    .|. wireBits 6 1 x
    .|. wireBits 7 0 x

-- | Return a number which is all zeros besides at the write position it has the bit read from the read position of the input.
wireBits :: Int -> Int -> Word8 -> Word8
wireBits bitToRead bitToSet x
  | testBit x bitToRead = bit bitToSet
  | otherwise = 0
