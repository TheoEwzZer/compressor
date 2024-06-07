# Image Compressor

A pretty basic way to compress image consists in reducing the number of colors it contains.
3 steps are needed to do so:

1. **read** the image and **extract** the colors of each pixel,
2. **cluster** these colors, and **replace** each color of a given cluster by the mean color of this cluster,
3. **index** the means of the cluster, and **create** the compressed image.

In this project, the first and third steps, reading from and writing into images, are considered as bonus.
You are to focus on the second part of the process: **clustering**.

From a file listing all the pixels of the image with their position and color, regroup them into a given number
of clusters, according to their colors.

```
You HAVE to use the k-means algorithm for clustering.
```

```
Remember how k-means work? At every step, compute a new bunch of k centroids and
add data to its nearest centroid, as in a Voronoi space, until the algorithm converges.
```

```
k-means work with a distance on the data space. You can simply use the euclidean distance
```

To test the convergence of the algorithm, use the convergence limit given as parameter. convergence is considered reached when all the clusters have moved less than the convergence parameter since the last iteration.

```
∼/B-FUN-400> ./imageCompressor
USAGE: ./imageCompressor -n N -l L -f F

  N    number of colors in the final image
  L    convergence limit
  F    path to the file containing the colors of the pixels
```

## INPUT

You should read the list of pixels from a file passed as argument, according to the following grammar:

```
IN     ::= POINT ' ' COLOR ('\n' POINT ' ' COLOR)*
POINT ::= '(' int ',' int ')'
COLOR ::= '(' SHORT ',' SHORT ',' SHORT ')'
SHORT ::= ' 0 '..' 255 '
```

For example,

```
∼/B-FUN-400> head exampleIn
(0,0) (33,18,109)
(0,1) (33,18,109)
(0,2) (33,21,109)
(0,3) (33,21,112)
(0,4) (33,25,112)
(0,5) (33,32,112)
(1,0) (33,18,109)
(1,1) (35,18,109)
(1,2) (35,21,109)
(1,3) (38,21,112)
```

## OUTPUT

You should print the list of clustered colors on the standard output, according to the following grammar:

```
OUT     ::= CLUSTER*
CLUSTER ::= '--\n' COLOR '\n-\n' (POINT ' ' COLOR '\n')*
POINT   ::= '(' int ',' int ')'
COLOR   ::= '(' SHORT ',' SHORT ',' SHORT ')'
SHORT   ::= ' 0 '..' 255 '
```

For example,

```
∼/B-FUN-400> ./imageCompressor -n 2 -l 0.8 -f in
--
(77,63,204)
-
(0,1) (98,99,233)
(2,0) (88,77,211)
(0,2) (45,12,167)
--
(35,36,45)
-
(1,0) (33,16,94)
(1,1) (78,8,9)
(1,2) (20,27,67)
(2,1) (1,56,37)
(0,0) (66,20,26)
(2,2) (15,89,40)
```

```
The color in the header of the cluster is the mean color.
```

```
You might have a slightly different result due to randomness...
```

## FINAL AMRK

### MARK: 44 / 44 (100%)

-   1 cluster (4 / 4)
-   2 clusters (22 / 22)
-   3 clusters (7 / 7)
-   4 clusters (6 / 6)
-   5 clusters (4 / 4)
-   16 clusters (1 / 1)
