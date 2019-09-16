#install.packages(c("dbplyr", "magrittr"))
library("dplyr")
library(magrittr)

setwd('')
con <- src_sqlite("euro_soccer.sqlite")

long_team_name <- 'Roma'
#each of the followint tables are just dplyr connections to the database tables
#if or when I need to bring the table to local memory I need to run table <- collect(table)
country_tbl <- tbl(con, "country")
league_tbl <- tbl(con, "league")
match_tbl <- tbl(con, "match")
player_tbl <- tbl(con, "player")
player_atts_tbl <- tbl(con, "player_attributes")
team_tbl <- tbl(con, "team")
team_atts_tbl <- tbl(con, "team_attributes")

roma_record <- team_tbl %>% 
                collect() %>%
                filter(grepl(long_team_name, team_long_name))

home_matches <- filter(match_tbl, home_team_api_id == roma_record$team_api_id)

match_outcomes_per_match <- match_tbl %>% 
                    mutate(goal_diff =home_team_goal - away_team_goal) %>% 
                    select(id, goal_diff) %>%
                    rename(match_id = id)

roma_players_per_match <- select(home_matches, id,matches("home_player_[[:digit:]]")) %>%
                collect() %>%
                # the gather function is a method in the tidyr package. It lets me turn un-tidy data into tidy data
                # take a loook at the difference between the output of just the previous line an then all lines together
                # can you see how why the previous output was not tidy data?
                gather(player, player_api_id, -id) %>%
                rename(match_id = id)