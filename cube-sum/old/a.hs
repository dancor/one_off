-- Calculate integer solutions to:
-- a^3 + b^3 = c^3 + d^3, a > b, a > c, c > d. Implies c > b.

import Data.Functor
import qualified Data.HashTable.IO as H
import Data.Maybe
import Data.Word
import Math.NumberTheory.Powers.Cubes
import System.Environment

type N = Word64

type H = H.BasicHashTable N N

cubeRootN :: N -> N
cubeRootN w
    | r > 2642245       = 2642245
    | w < c             = r-1
    | c < w && e < w && c < e  = r+1
    | otherwise         = r
      where
        r = truncate ((fromIntegral w) ** (1/3) :: Double)
        c = r*r*r
        d = 3*r*(r+1)
        e = c+d

-- Largest x where 2x^3 doesn't overflow.
cubeMax :: N
cubeMax = 2097151

genH :: N -> IO H
genH a = do
    h <- H.newSized (fromIntegral a)
    mapM_ (\n -> H.insert h (n * n * n) n) [1 .. a]
    return h

givenA :: H -> N -> IO [(N, N, N, N)]
givenA h a = concat <$> mapM (givenAB h a (a * a * a)) [1 .. a - 2]

givenAB :: H -> N -> N -> N -> IO [(N, N, N, N)]
givenAB h a a3 b = catMaybes <$> mapM (givenABC h a b a3b3) [cMin .. a - 1]
  where
    a3b3 = a3 + b * b * b
    cMin = ceiling $ (fromIntegral a3b3 / 2) ** (1 / 3)

givenABC :: H -> N -> N -> N -> N -> IO (Maybe (N, N, N, N))
givenABC h a b a3b3 c = do
    --fmap ((,,,) a b c) <$>
    --H.lookup h (a3b3 - c * c * c)
    let d3 = a3b3 - c * c * c
        d = cubeRootN d3
    return $ if d * d * d == d3 then Just (a,b,c,d) else Nothing

readMb :: Read a => String -> Maybe a
readMb s = fmap fst . listToMaybe $ reads s

pool :: IO ()
pool = do
    -- h <- genH cubeMax
    h <- genH 99986
    error "todo"
    return ()

main :: IO ()
main = do
    args <- getArgs
    let usage = "cube-sum [integer-value-of-a|pool]"
    case args of
      ["pool"] -> pool
      [nStr] -> case readMb nStr of
        Just a -> do
          --h <- genH a
          --res <- givenA h a
          res <- givenA (error "lol") a
          mapM_ print res
        _ -> error usage
      _ -> error usage
