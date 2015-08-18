shinyServer(function(input, output){
	
	observe({
		if(input$submitbtn == 0){
			return()
		} else {
			### read info into a data frame
			isolate({
				memb <- unlist(lapply(roles_list, function(x) x <- input[[x]]))
				print(memb)

				attend <- data.frame(role = roles_list, 
									member = memb, 
									date = rep(input$meeting_date, length(roles_list))
									)

			write.csv(attend, "test.csv")

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