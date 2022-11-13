# ---- function

tashizan <- function(a, b) {
  if ((class(a) == "numeric") == FALSE | (class(b) == "numeric") == FALSE) {
    stop("input number")
  }
  a +b 
}

# ---- file io
# file read
# by readr package
dat2 <- read_csv("SampleData-master/csv/Sales.csv")

# row.names option is false as default
write_csv(iris, "iris_tidy.csv'")

# library(readxl)
dat_xl <- read_excel("SampleData-master/xlsx/Sales.xlsx", sheet=1)
