library(dplyr)
library(stringr)
library(readr)
library(forcats)
library(DescTools)
library(epitools)
library(pROC)
library(ggplot2)

# andmete sisselugemine
andmed <- read.csv(
  file = "C:/Users/Kakumäe/OneDrive/Desktop/AnnaK/dataset.csv",
  fileEncoding = "UTF-8"
)

# tunnuste nimide vahetus eesti keelde
andmed <- andmed %>%
  rename(
    sugu = Gender,
    vanus = Age.Group,
    suitsetamine = Smoking.Habit,
    uni = Sleep.Duration
  )

# tekstide puhastus
andmed <- andmed %>%
  mutate(across(where(is.character), ~ str_trim(str_to_lower(.x))))

# sugu
andmed <- andmed %>%
  mutate(
    sugu = case_when(
      sugu %in% c("m", "male") ~ "mees",
      sugu %in% c("f", "female") ~ "naine",
      TRUE ~ NA_character_
    )
  )

# vanus ja vanusegrupp
andmed <- andmed %>%
  mutate(
    vanus = as.numeric(vanus),
    vanusegrupp = case_when(
      vanus >= 17 & vanus <= 24 ~ "17-24",
      vanus >= 25 & vanus <= 34 ~ "25-34",
      vanus >= 35 ~ "35+",
      TRUE ~ NA_character_
    )
  )

# suitsetamine
andmed <- andmed %>%
  mutate(
    suitsetamine = case_when(
      suitsetamine %in% c("yes", "y") ~ "jah",
      suitsetamine %in% c("no", "n") ~ "ei",
      TRUE ~ NA_character_
    )
  )

# une kestuse teisendamine arvuliseks
uni_parandus <- function(x) {
  x <- str_trim(str_to_lower(x))
  x <- str_replace_all(x, "hrs|hr|hours|hour", "")
  x <- str_trim(x)
  
  sapply(x, function(val) {
    if (is.na(val) || val == "") return(NA_real_)
    
    if (str_detect(val, ":")) {
      parts <- str_split(val, ":", simplify = TRUE)
      h <- suppressWarnings(as.numeric(parts[1]))
      m <- suppressWarnings(as.numeric(parts[2]))
      return(h + m / 60)
    }
    
    return(suppressWarnings(as.numeric(val)))
  })
}

andmed <- andmed %>%
  mutate(
    uni_tunnid = uni_parandus(uni),
    lyhike_uni = case_when(
      uni_tunnid < 7 ~ "jah",
      uni_tunnid >= 7 ~ "ei",
      TRUE ~ NA_character_
    )
  )

# puhas analüüsiandmestik
puhas_andmed <- andmed %>%
  select(
    sugu,
    vanus,
    vanusegrupp,
    suitsetamine,
    uni_tunnid,
    lyhike_uni
  ) %>%
  filter(
    !is.na(sugu),
    !is.na(vanusegrupp),
    !is.na(suitsetamine),
    !is.na(lyhike_uni)
  ) %>%
  mutate(
    sugu = factor(sugu),
    vanusegrupp = factor(vanusegrupp, levels = c("17-24", "25-34", "35+")),
    suitsetamine = factor(suitsetamine, levels = c("ei", "jah")),
    lyhike_uni = factor(lyhike_uni, levels = c("ei", "jah"))
  )

table(puhas_andmed$vanusegrupp)
prop.table(table(puhas_andmed$vanusegrupp))
table(puhas_andmed$suitsetamine, puhas_andmed$lyhike_uni)

# reaprotsendid
prop.table(table(puhas_andmed$suitsetamine, puhas_andmed$lyhike_uni), 1)

# Fisheri täpne test
fisher.test(table(puhas_andmed$suitsetamine, puhas_andmed$lyhike_uni))

# G-test
GTest(table(puhas_andmed$suitsetamine, puhas_andmed$lyhike_uni))

# šansside suhe ja 95% usaldusvahemik
oddsratio(table(puhas_andmed$suitsetamine, puhas_andmed$lyhike_uni))

# sagedustabelid soo kaupa
table(puhas_andmed$suitsetamine, puhas_andmed$lyhike_uni, puhas_andmed$sugu)

# Cochran-Mantel-Haenszeli test
mantelhaen.test(table(
  puhas_andmed$suitsetamine,
  puhas_andmed$lyhike_uni,
  puhas_andmed$sugu
))

# logistiline regressioon
m1 <- glm(
  lyhike_uni ~ suitsetamine + sugu + vanusegrupp,
  family = binomial(),
  data = puhas_andmed
)

summary(m1)

# OR-id ja 95% usalduspiirid
exp(cbind(OR = coef(m1), confint(m1)))

table(puhas_andmed$suitsetamine, puhas_andmed$vanusegrupp)
prop.table(table(puhas_andmed$suitsetamine, puhas_andmed$vanusegrupp), 1)

mantelhaen.test(table(
  puhas_andmed$suitsetamine,
  puhas_andmed$lyhike_uni,
  puhas_andmed$vanusegrupp
))

# mudelite võrdlus
m0 <- glm(
  lyhike_uni ~ sugu + vanusegrupp,
  family = binomial(),
  data = puhas_andmed
)

m1 <- glm(
  lyhike_uni ~ suitsetamine + sugu + vanusegrupp,
  family = binomial(),
  data = puhas_andmed
)

anova(m0, m1, test = "Chisq")

# joonis
joonis <- puhas_andmed %>%
  group_by(suitsetamine, lyhike_uni) %>%
  summarise(n = n(), .groups = "drop") %>%
  group_by(suitsetamine) %>%
  mutate(prop = n / sum(n))

ggplot(joonis, aes(x = suitsetamine, y = prop, fill = lyhike_uni)) +
  geom_col(position = "fill") +
  labs(
    x = "Suitsetamine",
    y = "Osakaal",
    fill = "Lühike uni"
  ) +
  scale_y_continuous(labels = scales::percent) +
  theme_minimal()
