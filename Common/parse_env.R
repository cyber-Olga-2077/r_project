parse_env <- function () {
  stored_dir <- getwd()

  setwd("~/r_test")
  env <- readLines(".env") %>% data.frame()

  matches <- regmatches(env$., regexpr("=", env$.), invert = TRUE)

  for (i in seq_len(nrow(env))) {
    env$key[i] <- matches[[i]][1]
    env$value[i] <- matches[[i]][2]
  }

  env <- subset(env, select = -.)

  setwd(stored_dir)

  return(env)
}
