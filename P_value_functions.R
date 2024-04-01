##This code reads in the effect estimates and confidence intervals from the analyses and creates P-value function graphs

#install.packages("pvaluefunctions")
#install.packages("epitools")
#install.packages("ggtext")
#install.packages("viridis")
library(epitools)
library(pvaluefunctions)
library(tidyverse)
library(grid)
library(gridExtra)
library(cowplot)
library(extrafont)
library(ggtext)
library(viridis)
loadfonts(device = c("all", "pdf", "postscript", "win"), quiet = TRUE)
Sys.setenv(R_GSCMD="C:/Program Files/gs/gs10.01.1/bin/gswin64.exe")

getwd()

font_family <-"Arial Rounded MT Bold"

values <-read.csv("<path>\\EffectEstimates.csv") 

baseline_est <-values$baseline
num<-c(rep(2410,3))

values$baseline_width <-((values$baseline - values$baseline_lb)+(values$baseline_ub - values$baseline))/2
values$baseline_se <-values$baseline_width/1.96
baseline_se <-values$baseline_se


res <- conf_dist(
  estimate = baseline_est
  , n = num
  , stderr = baseline_se
  , est_names = values$model
  , xlim= c(-1, 15)
  , type = "general_z"
  , trans = "identity"
  , plot_type = "p_val"
  , n_values = 1e4L
  , null_values=c(0)
  , conf_level = c(0.95)
  , alternative = "two_sided"
  , plot=FALSE
)


pfunc <-tibble(res$res_frame$values, res$res_frame$p_two, res$res_frame$variable)
names(pfunc)<-list("RD", "p", "model")
summary(pfunc$p)
pfunc<-subset(pfunc, !is.na(pfunc$RD))


f71<-ggplot(pfunc, aes(x = RD, y = p, color = model, linetype = model))+
  geom_line(linewidth= 1)+
  scale_x_continuous(limits=c(-1,14), breaks = c(0, 5, 7, 10), labels = c(0, 5, 7, 10))+
  scale_y_continuous(expand=c(0,0), limits = c(0,1.1), breaks = c(seq(0, 1, by=0.2), 0.05), labels = c(seq(0,1, by =0.2), 0.05))+
  geom_vline(aes(xintercept = 0), linewidth = 1, linetype = "dotted", color = grey(0.75, 1))+
  geom_hline(aes(yintercept = 0.05), linewidth = 1, linetype = "dotted", color = grey(0.75, 1))+
  scale_color_viridis(discrete = TRUE, option = "B", name = "Covariate set", end = 0.75 ) +
  scale_linetype_manual(values=c("solid", "longdash", "dashed"), guide = NULL )+
  xlab("Risk difference")+
  ylab("P-value")+
  ggtitle("(A) Baseline adjusted results")+
  theme(plot.margin = margin(10, 15, 10, 15),
        panel.border = element_blank(),
        panel.background = element_rect(fill = "white"),  # Set background color to white
        panel.grid.major = element_blank(),               # Remove major grid lines
        panel.grid.minor = element_blank(),               # Remove minor grid lines
        axis.line = element_line(color = "black"),         # Set axes color to black
        text = element_text(family = font_family) ,  # Set font to Arial Rounded Black
        axis.text = element_text(size = 16, color = "black"),              # Set font size of tick mark labels
        axis.title = element_text(size = 16)  ,             # Set font size of axis labels
        plot.title = element_text(hjust = 0.5, size = 16)   ,          # Center align the plot title
  )
f71


tv_est <-values$tv

values$tv_width <-((values$tv - values$tv_lb)+(values$tv_ub - values$tv))/2
values$tv_se <-values$tv_width/1.96
tv_se <-values$tv_se


res2 <- conf_dist(
  estimate =tv_est
  , n = num
  , stderr = tv_se
  , est_names = values$model
  , type = "general_z"
  , xlim= c(-4, 11)
  , trans = "identity"
  , plot_type = "p_val"
  , n_values = 1e4L
  , null_values=c(0)
  , conf_level = c(0.95)
  , alternative = "two_sided"
  , plot=FALSE
)

pfunc2 <-tibble(res2$res_frame$values, res2$res_frame$p_two, res2$res_frame$variable)
names(pfunc2)<-list("RD", "p", "model")
summary(pfunc2$p)
pfunc2<-subset(pfunc2, !is.na(pfunc2$RD))

f72<-ggplot(pfunc2, aes(x = RD, y = p, color = model, linetype = model))+
  geom_line(linewidth= 1)+
  scale_x_continuous(limits=c(-4,11), breaks = c(-2.5, 0, 2.5, 5, 7.5, 10), labels = c(-2.5, 0, 2.5, 5, 7.5, 10))+
  scale_y_continuous(expand=c(0,0), limits = c(0,1.1), breaks = c(seq(0, 1, by=0.2), 0.05), labels = c(seq(0,1, by =0.2), 0.05))+
  geom_vline(aes(xintercept = 0), linewidth = 1, linetype = "dotted", color = grey(0.75, 1))+
  geom_hline(aes(yintercept = 0.05), linewidth = 1, linetype = "dotted", color = grey(0.75, 1))+
  scale_color_viridis(discrete = TRUE, option = "B", name = "Covariate set", end = 0.75 ) +
  scale_linetype_manual(values=c("solid", "longdash", "dashed"), guide = NULL )+
  xlab("Risk difference")+
  ylab("P-value")+
  ggtitle("(B) IPW results")+
  theme(plot.margin = margin(10, 15, 10, 15),
        panel.border = element_blank(),
        panel.background = element_rect(fill = "white"),  # Set background color to white
        panel.grid.major = element_blank(),               # Remove major grid lines
        panel.grid.minor = element_blank(),               # Remove minor grid lines
        axis.line = element_line(color = "black"),         # Set axes color to black
        text = element_text(family = font_family) ,  # Set font to Arial Rounded Black
        axis.text = element_text(size = 16, color = "black"),              # Set font size of tick mark labels
        axis.title = element_text(size = 16)  ,             # Set font size of axis labels
        plot.title = element_text(hjust = 0.5, size = 16)   ,          # Center align the plot title
  )
f72


f71 
f72

