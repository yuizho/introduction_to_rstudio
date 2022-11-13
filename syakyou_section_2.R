# install.packages("tidyverse")
# library(rvest)

kabu_url <- "https://kabutan.jp/stock/kabuka?code=0000"

url_res <- read_html(kabu_url)
# probably the "css" option means "css selector"
url_title <- html_element(url_res, css="head > title")
# convert html_node to str
title <- html_text(url_title)

# fluent code by pipe operator
title2 <- read_html(kabu_url) %>%
  html_element(css="head > title") %>%
  html_text()


kabuka <- read_html(kabu_url) %>%
  html_element(xpath="//*[@id='stock_kabuka_table']/table[2]") %>%
  html_table()
