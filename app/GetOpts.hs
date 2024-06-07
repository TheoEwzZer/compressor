{-
-- EPITECH PROJECT, 2024
-- imageCompressor
-- File description:
-- imageCompressor
-}

module GetOpts (getOpts, Conf(nbColors, limit, filePath)) where

import Options.Applicative

data Conf = Conf {
  nbColors :: Int,
  limit    :: Float,
  filePath :: String
}

getOpts :: Parser Conf
getOpts = Conf
  <$> option auto
      ( short 'n' <> metavar "N"
     <> help "Number of colors in the final image" )
  <*> option auto
      ( short 'l' <> metavar "L"
     <> help "Convergence limit" )
  <*> strOption
      ( short 'f' <> metavar "F"
     <> help "Path to the file containing the colors of the pixels" )
