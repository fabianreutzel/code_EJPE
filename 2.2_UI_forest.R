################################################################################/
#title:   2.2_UI_forest
#author:  Fabian Reutzel
#content: 
#     0. Define bootstrap function for UI (i.e., IOp) estimates
#     1. Conditional Inference Forests (Brunori et al., 2023)
################################################################################/

#load packages
lapply(c("dineq","boot","party","dplyr"),library,character.only=TRUE)

#set circumstances & WD & sample definition
circumstances <- c("urban_birth","minority","pcommunist","fedu_4adj","medu_4adj")
setwd("C:/Users/f.reutzel/OneDrive - Université Paris 1 Panthéon-Sorbonne/IOP and attitudes project/Fabian/data/working/")
sample_def <- c("complete","incomplete","complete_all")

#set model parameters following (Brunori et al., 2019)
set.seed(12345) 
ntree<-200
nboot<-200
mtry<-4
alpha<-0.01

################################################################################/
#0. Define bootstrap function for UI (i.e., IOp) estimates####
################################################################################/
boot_iop<-function(data, indices) {
  #generate random sample
  dt <- data[indices,]
  #run forest using the created sample
  cforest <- cforest(as.formula(paste("y~",paste(circumstances, collapse="+"),sep = "")),
                     data=dt, weights=dt$fw, control=cforest_control(mincriterion = alpha, teststat="max", testtype="Bonferroni", ntree=ntree, mtry=mtry, trace=TRUE,replace=FALSE,fraction=0.75))
  #get predicted outcome
  dt$y_hat<-predict(cforest)
  #summarize predicted distribution
  c(
    abs_iop<-gini.wtd(dt$y_hat, weights=dt$fw), 
    abs_iop_mld<-mld.wtd(dt$y_hat, weights=dt$fw),
    gini<-gini.wtd(dt$y, weights=dt$fw),  
    mld<-mld.wtd(dt$y, weights=dt$fw),
    rel_iop<-abs_iop/gini,
    rel_iop_mld<-abs_iop_mld/mld
  )
}

################################################################################/
#1. Conditional Inference Forests (Brunori et al., 2023)####
################################################################################/
for (s in 1:length(sample_def)) {
  #load relevant dataset & apply restrictions based on sample definition
  print(sample_def[s])	
  ifelse(sample_def[s]!="complete_all", tree <- read.csv("LiTS_IOp_data.csv"),  tree <- read.csv("LiTS_IOp_data_all.csv"))
  if(sample_def[s]!="incomplete"){tree <- tree %>% filter_at(vars(paste0(circumstances)),all_vars(!is.na(.)))}
  tree <- tree %>% 
    mutate_at(vars(urban_birth,minority,pcommunist),~factor(.,levels=c(0,1))) %>% 
    mutate_at(vars(fedu_4adj,medu_4adj),~factor(.,levels=c(0,1,2,3)))
  
  #generate IOp dataset to be filled
  countries <- unique(tree$country)
  iop<-data.frame(countries)
  #point estimates
  iop$abs_iop_p<-NaN
  iop$abs_iop_mld_p<-NaN
  iop$rel_iop_p<-NaN
  iop$rel_iop_mld_p<-NaN
  iop$gini_p<-NaN
  iop$mld_p<-NaN
  #upper bound
  iop$abs_iop_u<-NaN
  iop$abs_iop_mld_u<-NaN
  iop$rel_iop_u<-NaN
  iop$rel_iop_mld_u<-NaN
  iop$gini_u<-NaN
  iop$mld_u<-NaN
  #lower bound
  iop$abs_iop_l<-NaN
  iop$abs_iop_mld_l<-NaN
  iop$rel_iop_l<-NaN
  iop$rel_iop_mld_l<-NaN
  iop$gini_l<-NaN
  iop$mld_l<-NaN
  
  for (j in 1:length(countries)) {
    #get relevant country data
  	tr<-tree[tree$country==countries[j],]
  	print(countries[j])	
  	
  	#run bootstrap
  	tryCatch({
  	boot_results <-boot(tr,boot_iop, R=nboot)
  	}, error=function(e){})
  	
  	ci1 <- boot.ci(boot_results, type="norm", index=1)
  	ci2 <- boot.ci(boot_results, type="norm", index=2)
  	ci3 <- boot.ci(boot_results, type="norm", index=3)
  	ci4 <- boot.ci(boot_results, type="norm", index=4)
  	ci5 <- boot.ci(boot_results, type="norm", index=5)
  	ci6 <- boot.ci(boot_results, type="norm", index=6)
  	
  	#save results
  	#point estimates
  	iop$abs_iop_p[j]<-ci1$t0[1]
  	iop$abs_iop_mld_p[j]<-ci2$t0[1]
  	iop$gini_p[j]<-ci3$t0[1]
  	iop$mld_p[j]<-ci4$t0[1]
  	iop$rel_iop_p[j]<-ci5$t0[1]
  	iop$rel_iop_mld_p[j]<-ci6$t0[1]
  	#upper bound
  	iop$abs_iop_u[j]<-ci1$normal[3]
  	iop$abs_iop_mld_u[j]<-ci2$normal[3]
  	iop$gini_u[j]<-ci3$normal[3]
  	iop$mld_u[j]<-ci4$normal[3]
  	iop$rel_iop_u[j]<-ci5$normal[3]
  	iop$rel_iop_mld_u[j]<-ci6$normal[3]
  	#lower bound
  	iop$abs_iop_l[j]<-ci1$normal[2]
  	iop$abs_iop_mld_l[j]<-ci2$normal[2]
  	iop$gini_l[j]<-ci3$normal[2]
  	iop$mld_l[j]<-ci4$normal[2]
  	iop$rel_iop_l[j]<-ci5$normal[2]
  	iop$rel_iop_mld_l[j]<-ci6$normal[2]
  }
  write.csv(iop, file=paste0("iop_forest_",sample_def[s],".csv"))
}