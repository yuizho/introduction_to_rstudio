# tidy data
scores_messy <- data.frame(
  名前 = c("生徒A", "生徒B"),
  算数 = c(100, 100),
  国語 = c(80, 100),
  理科 = c(60, 100),
  社会 = c(40, 20)
)

library(tidyverse)

scores_tidy <- pivot_longer(scores_messy,
  cols = c(算数, 国語, 理科, 社会),
  names_to = "教科",
  values_to = "点数"
)

pivot_wider(scores_tidy,
            names_from = 教科,
            values_from = 点数
)

# dplyrによる基本的なデータ操作
# tibble
d <- data.frame(x = 1:3)
d[, "x"]
d_tibble <- as_tibble(d)
d_tibble[, "x"]

# dplyr
mpg %>%
  # 射影
  select(manufacturer, MODEL=model, displ, year, cyl) %>%
  # 条件による絞り込みも可能
  #select(starts_with("c"))
  # filter
  filter(manufacturer == "audi") %>%                
  # sort. `-` つけるとdesc. 
  arrange(-cyl) %>%
  # 文字列の降順はdesc関数でくるむ
  #arrange(desc(manufacturer)) %>%
  # 列の追加
  mutate(century = ceiling(year / 100)) %>%
  mutate(cyl_6 = if_else(cyl >= 6, "6以上", "6未満"), .after = cyl)
  
# グルーピングして
mpg_grouped <- mpg %>%
  group_by(manufacturer, year)
# グループ内順位 (サマリーはせずあくまでグループ内での順位がでる)
mpg_grouped %>%
  transmute(displ_rank = rank(displ, ties.method = "max"))
# summarise (グループごとの最大値)
# グループ化されたままだと後続のfilter処理とかの動きが予期しないものになったりするので、dropしてやるのがよい
mpg_grouped %>%
  summarise(displ_max = max(displ), .groups = "drop")

# window関数例
uriage <- tibble(
  day = c(1, 1, 2, 2, 3, 3, 4, 4),
  store = c("a", "b", "a", "b", "a", "b", "a", "b"),
  sales = c(100, 500, 200, 500, 400, 500, 800, 500)
)
# lag関数で店舗ごとに前日のデータとの差分を計算
uriage %>%
  group_by(store) %>%
  mutate(sales_diff = sales - lag(sales)) %>%
  mutate(
    sales_mean = mean(sales),      # 各店舗の平均売上
    sales_err = sales - sales_mean # 各日の売上と平均売上額との差額
  )
  arrange(store, day)

# inner_join例
tenko <- tibble(
  DAY = c(1, 1, 2, 2, 3),
  store = c("a", "b", "a", "b", "b"),
  rained = c(FALSE, FALSE, TRUE, FALSE, TRUE)
)
# dayとDAY and storeをkeyにしてinner join(データフレームの結合)する
uriage %>%
  inner_join(tenko, by=c("day" = "DAY", "store"))

# left_join例
uriage %>%
  left_join(tenko, by=c("day" = "DAY", "store")) %>%
  # left joinによるN/AをFALSEで置き換え
  mutate(rained = coalesce(rained, FALSE))

# semi_joinによるデータフレーム間の絞り込み
tenko2 <- tibble(
  day = c(2, 3, 3),
  store = c("a", "a", "b"),
  rained = c(TRUE, TRUE, TRUE)
)
uriage %>%
  semi_join(tenko2, by = c("day", "store"))

orders <- tibble(
 id = c(1, 2, 3) ,
 value = c("ラーメン_大", "半チャーハン_並", "ラーメン_並")
)
# 文字列を _ で分割してindex指定してmutate
# by str_split
orders %>%
  mutate(
    item = str_split(value, "_", simplify = TRUE)[, 1],
    amount = str_split(value, "_", simplify = TRUE)[, 2]
  )
# by separate
# sepは正規表現
orders %>%
  separate(value, into = c("item", "amount"), sep = "_")

# 暗黙の欠損値 (存在しないデータの組み合わせ) を表現する
orders2 <- tibble(
  day = c(1, 1, 1, 2),
  item = c("ラーメン", "ラーメン", '半チャーハン', "ラーメン"),
  size = c("大", "並", "並", "並"),
  order = c(3, 10, 3, 30)
)
# by complete
# 組み合わせを指定して、暗黙の欠損値を見つける (これだけだと本来ありえない組み合わせまでできてしまう)
orders2 %>%
  complete(day, item, size, fill = list(order = 0))

# netsingを使うと実際データ中に存在する組み合わせだけに絞ることができる！
orders2 %>%
  complete(day, nesting(item, size), fill = list(order = 0))

# セル結像的なデータの欠損値の保管
sales <- tibble(
  year = c(200, NA, NA, NA, 2001, NA, NA, NA),
  quarter = c("Q1", "Q2", "Q3", "Q4", "Q1", "Q2", "Q3", "Q4"),
  sales = c(100, 200, 300, 400, 500, 100, 200, 300)
)
sales %>%
  fill(year)
