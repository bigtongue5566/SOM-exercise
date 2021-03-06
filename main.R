set.seed(0)

calculate.nets <- function(input.vector,weights,x,y){
  nets <- matrix(colSums((input.vector - weights)^2),x,y)
  return(nets)
}

find.winning.node <- function(nets){
  min.position <- which(nets == min(nets), arr.ind = TRUE)
  return(min.position)
}


training <- function(data,xsize=10,ysize=10,training.rate=0.1,training.rate.shrink.rate=0.95,radius.shrink.rate=0.95) {
  x <- xsize
  y <- ysize
  radius <- (x^2 + y^2)^0.5
  average.total.distances <- c()
  count <- 0
  weights <- matrix(rep(0.5,x*y),ncol(data))  #matrix(round(runif(ncol(data)*x*y),2),ncol(data))
  repeat {
    output.topology <- matrix(rep(0,x*y),x,y)
    count <- count + 1
    total.distance <- 0
    for (i in 1:nrow(data)) {
      input.vector <- data[i,]
      nets <- calculate.nets(input.vector,weights,x,y)
      winning.node <- find.winning.node(nets)
      #calculate total distance for error measure
      total.distance <- total.distance + min(nets^0.5)
      #calculate the output vector Y for each output layer
      nets[] <- 0
      nets[winning.node[1,'row'],winning.node[1,'col']] <- 1
      #add minposition to output topology
      output.topology[winning.node[1,'row'],winning.node[1,'col']] <- output.topology[winning.node[1,'row'],winning.node[1,'col']] + 1
      #calculate delta weights
      distance <- matrix(rep(0,x*y),x,y)
      for (i in 1:x) {
        for (j in 1:y) {
          distance[i,j] <- ((i - winning.node[1,'row'])^2 + (j - winning.node[1,'col'])^2)^0.5
        }
      }
      neighborhood <- exp(-distance/radius)
      delta.weights = training.rate * t(t(input.vector - weights)*c(neighborhood))
      #update connecting weight matrix
      weights <- weights + delta.weights
    }
    radius <- radius * radius.shrink.rate
    training.rate <- training.rate * training.rate.shrink.rate
    average.total.distances[count] <- total.distance
    if (count >= 300) {
      break
    }
  }
  return(list(output.topology,average.total.distances))
}

recalling <- function(radius.shrink.rate=0.95, training.rate=0.9, training.rate.shrink.rate=0.95, xsize=10, ysize=10, weights, test.data){
  nets <- calculate.nets(test.data,weights,xsize,ysize)
  winning.node <- find.winning.node(nets)
  return(winning.node)
}



data.iris <- iris
iris.sepal.length <- scale(c(data.iris[,1]),center = FALSE)
iris.sepal.width <- scale(c(data.iris[,2]),center = FALSE)
iris.petal.length <- scale(c(data.iris[,3]),center = FALSE)
iris.petal.width <- scale(c(data.iris[,4]),center = FALSE)
data.iris <- cbind(iris.sepal.length,iris.sepal.width,iris.petal.length,iris.petal.width)
#randomize row
data.iris <- data.iris[sample(nrow(data.iris)),]
result <- training(data.iris)

topology <- result[[1]]
average.distances <- result[[2]]

X11()
plot(average.distances,type = "l",xlab = "Iteration",ylab = "Error")

#X11()
#persp(1:nrow(topology),1:ncol(topology),topology,theta = 30, col = "cyan", phi = 20,ticktype = "detailed")

library(rgl)
r3dDefaults$windowRect = c(50,50,720,720) 
nbcol = 100
color = rev(rainbow(nbcol, start = 0/6, end = 4/6))
zcol  = cut(topology, nbcol)
persp3d(1:nrow(topology),1:ncol(topology),topology, col = color[zcol],theta = 30, phi = 20,ticktype = "detailed",xlab = "X", ylab = "Y", zlab = "Frequency")
play3d(spin3d(axis = c(0, 0, 1), rpm = 6), duration = 10)
#movie3d(spin3d(axis = c(0, 0, 1), rpm = 6), duration = 10, movie = "outputfile", dir = getwd())