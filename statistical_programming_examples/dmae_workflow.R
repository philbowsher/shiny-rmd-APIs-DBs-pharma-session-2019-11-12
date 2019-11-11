library(haven)
library(tidyverse)
library(gglabeller)

dm <- read_sas("~/ACOP-2019-R-for-Drug-Development-Workshop/Data/dm.sas7bdat")

ae <- read_sas("~/ACOP-2019-R-for-Drug-Development-Workshop/Data/ae.sas7bdat")

dmae <- ae %>%
  left_join(dm, by = 'USUBJID') %>% rename(STUDYID = STUDYID.x ,  DOMAIN = DOMAIN.x) %>%
  select(-c(DOMAIN.y, STUDYID.y))
  
dmae

write_sas(dmae, "dmae.sas7bdat")
write_xpt(dmae, " dmae.xpt")

dplyr::glimpse(dmae)


ggplot(data = dmae, aes(x = AGE)) + 
  geom_density(fill = "blue")

dmae %>% summarize(
  min = min(AGE), 
  max = max(AGE))

range(dmae$AGE)

dmae %>% 
  group_by(SEX, AESEV) %>% 
  count()


p <- ggplot(data = dmae, # add the data
       aes(x = AESER, y = AGE, # set x, y coordinates
           color = AESER)) +    # color by treatment
  geom_boxplot() +
  facet_grid(~SEX) # create panes base on health status

gglabeller_example <- gglabeller(p, aes(label = rownames(dmae)))

dmae %>% Filter(f = is.factor) %>% names


dmae <- dmae %>% 
  mutate(
    SEX = factor(SEX),
    AESEV =  factor(AESEV),
    RACE = factor(RACE)
  )


dmae %>% Filter(f = is.factor) %>% names

sum_dmae <- dmae %>% 
  mutate(
    SEX = factor(SEX),
    AESEV =  factor(AESEV),
    RACE = factor(RACE)
  )

dplyr::glimpse(sum_dmae)

sum_dmae <- sum_dmae %>%   
  group_by(SEX, RACE, AESEV) %>%  
  summarize(AGE_mean = mean(AGE),   
            AGE_se = sd(AGE)/sqrt(n()),
            n_samples = n()) %>%
  ungroup() # ungrouping variable is a good habit to prevent errors

ggplot(data = sum_dmae, # add the data
       aes(x = AESEV,  #set x, y coordinates
           y = AGE_mean,
           group = AESEV,  # group by treatment
           color = AESEV)) +    # color by treatment
  geom_point(size = 3) + # set size of the dots
  facet_grid(SEX~RACE) # create facets by sex and status



dmae_final <- dmae %>% filter(AGE >= 80)

ggplot(data = dmae_final) +
  geom_point(mapping = aes(x = SEX, y = AGE))

