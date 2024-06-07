{-
-- EPITECH PROJECT, 2024
-- imageCompressor
-- File description:
-- imageCompressor
-}

module Main (main) where

import Control.Exception (catch, IOException)
import Data.List (nub)
import Lib (distance)
import GetOpts (getOpts, Conf(nbColors, limit, filePath))
import Options.Applicative
import System.Environment (getArgs)
import System.Exit (exitWith, ExitCode(ExitFailure))
import System.Random (randomRIO)
import Text.Read (readMaybe)

type Color = (Int, Int, Int)
type Point = (Int, Int)

data Pixel = Pixel {
  pixelPosition :: Point,
  pixelColor :: Color
} deriving (Show)

data Cluster = Cluster {
  clusterColor :: Color,
  clusterPixels :: [Pixel]
} deriving (Show)

createPixel :: String -> IO Pixel
createPixel line | [pointStr, colorStr] <- words line,
                   Just position <- readMaybe pointStr :: Maybe Point,
                   Just color <- readMaybe colorStr :: Maybe Color
                   = return (Pixel position color)
                 | otherwise = exitWith (ExitFailure 84)

parseInput :: String -> IO [Pixel]
parseInput input = mapM createPixel (lines input)

main :: IO ()
main = do
  args <- getArgs
  let prefs' = prefs showHelpOnError
  let opts = info (getOpts <**> helper) fullDesc
  let parserResult = execParserPure prefs' opts args
  handleResult parserResult

handleResult :: ParserResult Conf -> IO ()
handleResult (Success conf) = checkConf conf
handleResult (Failure failure) =
  putStrLn (fst (renderFailure failure "")) >> exitWith (ExitFailure 84)
handleResult (CompletionInvoked completion) =
  execCompletion completion "" >> exitWith (ExitFailure 84)

checkConf :: Conf -> IO ()
checkConf conf
  | nbColors conf <= 0  = exitWith (ExitFailure 84)
  | limit conf < 0      = exitWith (ExitFailure 84)
  | filePath conf == "" = exitWith (ExitFailure 84)
  | otherwise           = imageCompressor conf

randomPixelColors :: [Pixel] -> Int -> IO [Color]
randomPixelColors pixels k 
  | k > length colors = putStrLn "Error: Not enough unique colors." >>
  exitWith (ExitFailure 84)
  | otherwise = selectRandomColors colors k
  where colors = nub (map pixelColor pixels)

selectRandomColors :: [Color] -> Int -> IO [Color]
selectRandomColors _ 0 = return []
selectRandomColors colors n = do
  randomIndex <- randomRIO (0, length colors - 1)
  let (selectedColor, remainingColors) = removeAt randomIndex colors
  remainingSelectedColors <- selectRandomColors remainingColors (n - 1)
  return (selectedColor : remainingSelectedColors)

removeAt :: Int -> [a] -> (a, [a])
removeAt index list = (removedElement, remainingList)
  where removedElement = list !! index
        remainingList = take index list ++ drop (index + 1) list

kMeans :: [Pixel] -> Int -> Float -> IO [Cluster]
kMeans pixels k limit' = do
  initialColors <- randomPixelColors pixels k
  let initialClusters = map (`Cluster` []) initialColors
  let newClusters = kMeans' pixels initialClusters limit'
  return newClusters

kMeans' :: [Pixel] -> [Cluster] -> Float -> [Cluster]
kMeans' pixels clusters limit'
  | maxShift < limit' = newClustersWithAverage
  | otherwise         = kMeans' pixels newClustersWithAverage limit'
  where
    newClusters = assignPixels pixels clusters
    newClustersWithAverage = averageCluster newClusters
    maxShift = calculateMaxShift clusters newClustersWithAverage

assignPixels :: [Pixel] -> [Cluster] -> [Cluster]
assignPixels pixels clusters = map (assignPixel pixels clusters) clusters

assignPixel :: [Pixel] -> [Cluster] -> Cluster -> Cluster
assignPixel pixels clusters (Cluster color _) =
  Cluster color (filter (isClosest color clusters) pixels)

isClosest :: Color -> [Cluster] -> Pixel -> Bool
isClosest color clusters pixel =
  isClosest' color clusters pixel (distance (pixelColor pixel) color)

isClosest' :: Color -> [Cluster] -> Pixel -> Float -> Bool
isClosest' _ [] _ _ = True
isClosest' color (Cluster c _:cs) pixel minDistance
  | currentDistance < minDistance = False
  | otherwise = isClosest' color cs pixel (min currentDistance minDistance)
  where currentDistance = distance (pixelColor pixel) c

averageCluster :: [Cluster] -> [Cluster]
averageCluster = map averageClusterColor

averageClusterColor :: Cluster -> Cluster
averageClusterColor (Cluster _ pixels) = Cluster (averageColor pixels) pixels

averageColor :: [Pixel] -> Color
averageColor [] = (0, 0, 0)
averageColor pixels = averageColor' pixels (0, 0, 0, 0)

averageColor' :: [Pixel] -> (Int, Int, Int, Int) -> Color
averageColor' [] (r, g, b, c) = (r `div` c, g `div` c, b `div` c)
averageColor' (Pixel _ (r', g', b'):pixels) (r, g, b, c) =
  averageColor' pixels (r + r', g + g', b + b', c + 1)

calculateMaxShift :: [Cluster] -> [Cluster] -> Float
calculateMaxShift [] [] = 0
calculateMaxShift (Cluster c1 _:oldClusters) (Cluster c2 _:newClusters) =
  max (distance c1 c2) (calculateMaxShift oldClusters newClusters)
calculateMaxShift _ _ = error "Lists are not of the same length"

imageCompressor :: Conf -> IO ()
imageCompressor conf = catch (
  do
    input <- readFile (filePath conf)
    pixelData <- parseInput input
    clusters <- kMeans pixelData (nbColors conf) (limit conf)
    printClusters clusters
  ) exceptionHandler

exceptionHandler :: IOException -> IO ()
exceptionHandler _ = exitWith (ExitFailure 84)

printClusters :: [Cluster] -> IO ()
printClusters = mapM_ printCluster

printCluster :: Cluster -> IO ()
printCluster (Cluster color pixels) =
  putStrLn "--" >>
  printColor color >>
  putStrLn "\n-" >>
  mapM_ printPixel pixels

printPixel :: Pixel -> IO ()
printPixel (Pixel point color) =
  printPoint point >>
  putStr " " >>
  printColor color >>
  putStrLn ""

printColor :: Color -> IO ()
printColor (r, g, b) = putStr ("(" ++ show r ++ "," ++ show g ++
                               "," ++ show b ++ ")")

printPoint :: Point -> IO ()
printPoint (x, y) = putStr ("(" ++ show x ++ "," ++ show y ++ ")")
