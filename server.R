shinyServer(function(input, output){
	
	observe({
		if(input$submitbtn == 0){
			return()
		} else {
			### read info into a data frame
			isolate({
				### collect attendence info
				memb <- unlist(lapply(roles_list, function(x) x <- input[[x]]))

				attend <- data.frame(meeting_date = rep(input$meeting_date, length(roles_list)),
									role = roles_list, 
									name = memb)
				# attend$member[attend$member == "Not Applicable"] <- NA 

				### save attendence info
				sqlSave(tm, attend, 'meetings', append = TRUE, rownames = FALSE, nastring = NULL)

				### collect speech info
				# speech_info_list <- lapply(speaker_fields, function(x) x <- input[[x]])
				# speech_num <- unlist(lapply(speech_info_list, function(x) strsplit(x, ",")[[1]]))
				# title <- unlist(lapply(speech_info_list, function(x) strsplit(x, ",")[[2]]))
				# speeches_df <- data.frame(
				# 	name = c(input$Speaker1, input$Speaker2, input$Speaker3, input$Speaker4, input$Speaker5), 
				# 	speech_num = speech_num, 
				# 	title = title,
				# 	speech_date = input$meeting_date
				# )
				# speeches_df <- subset(speeches_df, name != "Not Applicable")
				# print(speeches_df)

				### save speech info to database
				# sqlSave(tm, speeches_df, 'speeches', append = TRUE, rownames = FALSE)

				# ### collect award info:
				# awardsdf <- data.frame(
				# 	award = awards_list, 
				# 	name = c(input$bs, input$be, input$btt), 
				# 	date = rep(input$meeting_date, 3)
				# )

				# ### save award info to datebase
				# sqlSave(tm, awardsdf, 'awards', append = TRUE, rownames = FALSE)

				### run list of sqlsave functions:
				# lapply(list(ssave1, ssave2, ssave3), f(x))
			})
		}	

	# output$sec_report <- downloadHandler(
	# 	filename = paste("attendance", date_hash, ".txt", sep = ""), 			
	# 	content = function(file){
	# 		write.table(attend, file, sep = "\t")
	# 			},
	# 	"text/plain"
	# )
	
	})
})
