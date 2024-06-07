{-
-- EPITECH PROJECT, 2024
-- imageCompressor
-- File description:
-- imageCompressor
-}

module Lib (distance) where

type Color = (Int, Int, Int)

distance :: Color -> Color -> Float
distance (r1, g1, b1) (r2, g2, b2) =
  sqrt ((fromIntegral r2 - fromIntegral r1) ** 2 + 
        (fromIntegral g2 - fromIntegral g1) ** 2 + 
        (fromIntegral b2 - fromIntegral b1) ** 2)
