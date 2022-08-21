library(httr)



get_base_prediction <- function(teamf = "GB", posf = "QB", expf = "3", fg_perf = "0", fg_blkf = "0", fumb_forcef = "0", fumb_returnf = "0", fumb_tdf = "0", int_intf = "0", 
                                int_lngf = "0", ko_ydsf = "0", ko_osk_recf = "0", ko_tdf = "0", ko_outboundsf =  "0", kor_avgf = "0", kor_ydsf = "0", kor_tdf = "0", 
                                kor_fumbf = "0", pass_tdf = "20", pass_intf = "10", pass_ratingf = "90", pen_penaltiesf = "0", pen_ydsf = "0", 
                                pen_presnapf = "0", pr_avgf = "0", pr_ydsf = "0", pr_longf = "0", pr_fumbf = "0", rec_ydsf = "0", rec_fumblef = "0", 
                                rush_ydsf = "0", rush_fumblef = "0", tack_combf = "0", tack_sackf = "0") {
       b_url <- "http://127.0.0.1:3626/regression"
       params <- list(team = teamf, pos = posf, exp = expf, fg_per = fg_perf, fg_blk = fg_blkf, fumb_force = fumb_forcef, fumb_return = fumb_returnf, fumb_td = fumb_tdf, int_int = int_intf, 
               int_lng = int_lngf, ko_yds = ko_ydsf, ko_osk_rec = ko_osk_recf, ko_td = ko_tdf, ko_outbounds =  ko_outboundsf, kor_avg = kor_avgf, kor_yds = kor_ydsf, kor_td = kor_tdf, 
               kor_fumb = kor_fumbf, pass_td = pass_tdf, pass_int = pass_intf, pass_rating = pass_ratingf, pen_penalties = pen_penaltiesf, pen_yds = pen_ydsf, 
               pen_presnap = pen_presnapf, pr_avg = pr_avgf, pr_yds = pr_ydsf, pr_long =  pr_longf, pr_fumb = pr_fumbf, rec_yds = rec_ydsf, rec_fumble = rec_fumblef, 
               rush_yds = rush_ydsf, rush_fumble = rush_fumblef, tack_comb = tack_combf, tack_sack = tack_sackf)
       query_url <- modify_url(url = b_url, query = params)
       resp_raw <- content(resp, as = "text", encoding = "UTF8")
       return(jsonlite::fromJSON(resp_raw))
 
}

get_base_prediction()

