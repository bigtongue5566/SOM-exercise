training <- function(data) {
  radius.shrink.rate <- 0.95
  learning.rate <- 0.9
  learning.rate.shrink.rate <- 0.95
  x <- 10
  y <- 10
  radius <- (x^2 + y^2)^0.5
  output.topology <- matrix(rep(0,x*y),x,y)
  total.distances <- c()
  count <- 0
  weights <- matrix(round(runif(ncol(data)*x*y),1),ncol(data))
  repeat {
    count <- count + 1
    total.distance <- 0
    for (i in 1:nrow(data)) {
      input.vector <- data[i,]
      #find the winning node
      nodes <- matrix(colSums((input.vector - weights)^2),x,y)
      min.position <- which(nodes == min(nodes), arr.ind = TRUE)
      #calculate total distance
      total.distance <- total.distance + min(nodes^0.5)
      #calculate the output vector Y for each output layer
      nodes[] <- 0
      nodes[min.position[1,'row'],min.position[1,'col']] <- 1
      #add minposition to output topology
      output.topology[min.position[1,'row'],min.position[1,'col']] <- output.topology[min.position[1,'row'],min.position[1,'col']] + 1
      #calculate delta weights
      distance <- matrix(rep(0,x*y),x,y)
      for (i in 1:x) {
        for (j in 1:y) {
          distance[i,j] <- ((i - min.position[1,'row'])^2 + (j - min.position[1,'col'])^2)^0.5
        }
      }
      neighborhood <- exp(-distance/radius)
      delta.weights = learning.rate * t(t(input.vector - weights)*c(neighborhood))
      #update connecting weight matrix
      weights <- weights + delta.weights
    }
    radius <- radius * radius.shrink.rate
    learning.rate <- learning.rate * learning.rate.shrink.rate
    total.distances[count] <- total.distance
    if (count >= 200 || mean(total.distances) < 1) {
      break
    }
  }
  print(output.topology)
  return(output.topology)
}
recalling <- function(){
  
}
data.iris <- iris
iris.sepal.length <- scale(c(data.iris[,1]))
iris.sepal.width <- scale(c(data.iris[,2]))
iris.petal.length <- scale(c(data.iris[,3]))
iris.petal.width <- scale(c(data.iris[,4]))
result <- training(cbind(iris.sepal.length,iris.sepal.width,iris.petal.length,iris.petal.width))

persp(1:nrow(result),1:ncol(result),result,theta = 30, col = "cyan", phi = 20,ticktype = "detailed",shade = 0.75)
#X11()
#library(plot3D)
#persp3D(1:nrow(result),1:ncol(result),result,theta = 30, phi = 20,ticktype = "detailed" )