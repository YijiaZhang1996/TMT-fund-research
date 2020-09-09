# This script is used to calculate turnover rate of funds
# To run this script, you need to install and library package "WindR" and "stringr" first
# ��������ɱ������������ָ��ֻ���걨�Ͱ��걨��¶����2020H1��δ��¶������ֻ���㵽2019��ĩ�����걨��¶����޸Ľӿ��е����ڲ���������2020H1
# 2020H1�����������Ҫ�껯��*2��

t1<-proc.time()

# Define fundemental variables
fund_code<-c("000940.OF","002692.OF","006751.OF","257070.OF","001513.OF","320007.OF","007490.OF","001071.OF","519674.OF","000697.OF","519772.OF",
             "000404.OF","110013.OF","002939.OF","610002.OF")
turnover_rate_result<-data.frame(matrix(NA, ncol=6, nrow = 0))

for(j in 1:length(fund_code)){
  manager_start_date<-as.Date(w.wss(fund_code[j],'fund_manager_startdate','order=1')$Data$FUND_MANAGER_STARTDATE,origin="1899-12-30")
  
  # ��ʼ�����������°��꣬�����������ݣ������꿪ʼ��
  if(as.numeric(substr(manager_start_date,6,7))>6){
    quarter_date_series<-w.tdays(manager_start_date,"2019-12-31","Days=Alldays;Period=Q")$Data$DATETIME
    year_date_series<-w.tdays(manager_start_date,"2019-12-31","Days=Alldays;Period=Y")$Data$DATETIME[-1]
    
    cost_and_income_list<-data.frame(matrix(NA, ncol=4, nrow = 0))
    # ����ӣ�ƽ�������֧����
    for(i in 1:length(year_date_series)){
      cost_and_income<-w.wss(fund_code[j],'prt_buystockcost,prt_sellstockincome','unit=1',paste0('rptDate=',year_date_series[i]))
      cost_and_income_list[i,1]<-fund_code[j]
      cost_and_income_list[i,2]<-as.character(year_date_series[i])
      cost_and_income_list[i,3]<-(cost_and_income$Data$PRT_BUYSTOCKCOST+cost_and_income$Data$PRT_SELLSTOCKINCOME)/2
      cost_and_income_list[i,4]<-substr(year_date_series[i],1,4)
    }
    colnames(cost_and_income_list)<-c("fund_code","date","average_cost_and_income","year")
    
    # ���ĸ������ƽ���ʲ���ֵ��
    stock_value_quarter<-data.frame(matrix(NA, ncol=3, nrow = 0))
    for(k in 1:length(quarter_date_series)){
      stock_value<-w.wss(fund_code[j],'prt_fundnetasset_total','unit=1',
                         paste0('rptDate=',quarter_date_series[k]))$Data$PRT_FUNDNETASSET_TOTAL
      # �ų�ĳЩ��Ʒ��������û����¶����������û���ʲ���ֵ���ݵ����
      if(stock_value!='NaN'){
        date<-as.character(quarter_date_series[k])
        year<-substr(quarter_date_series[k],1,4)
        stock_value_temp<-data.frame(matrix(c(date,stock_value,year),ncol=3))
        stock_value_quarter<-rbind(stock_value_quarter,stock_value_temp)
      }
    }
    colnames(stock_value_quarter)<-c("date","stock_value","year")
    
    # �����ʲ���ֵ���ݣ��������ƽ��ֵ,�õ���ĸ
    stock_value_year<-aggregate(as.numeric(stock_value_quarter$stock_value),list(stock_value_quarter$year),mean)
    colnames(stock_value_year)<-c("year","stock_value")
    
    # �ѷ��ӷ�ĸ����ֵ�����merge�����������
    merge_result<-merge(cost_and_income_list,stock_value_year,by=intersect(names(cost_and_income_list), names(stock_value_year)))
    merge_result$turnover_rate<-merge_result$average_cost_and_income/merge_result$stock_value
  }
  
  # ��ʼ�����������ϰ��꣬��ʹ�ø��������ǵ�����
  else{
    quarter_date_series<-w.tdays(manager_start_date,"2019-12-31","Days=Alldays;Period=Q")$Data$DATETIME
    year_date_series<-w.tdays(manager_start_date,"2019-12-31","Days=Alldays;Period=Y")$Data$DATETIME
    cost_and_income_list<-data.frame(matrix(NA, ncol=4, nrow = 0))
    stock_value_quarter<-data.frame(matrix(NA, ncol=3, nrow = 0))
    fund_setup_date<-w_wss_data<-as.Date(w.wss(fund_code[j],'fund_setupdate')$Data$FUND_SETUPDATE,origin="1899-12-30")
    
    # ����������ڵ��ڽӹ����ڣ�����ͳɱ���Ҫʹ���걨���ݵ��껯ֵ������ĩ����ؿ������������껯��
    if(fund_setup_date==manager_start_date){
      
      # ��ȡ��ؿ�����
      redm_start_date<-as.Date(w.wss(fund_code[j],'fund_redmstartdate')$Data$FUND_REDMSTARTDATE,origin="1899-12-30")
      interval_days<-as.numeric(difftime(year_date_series[1],redm_start_date))
      
      cost_and_income<-w.wss(fund_code[j],'prt_buystockcost,prt_sellstockincome','unit=1',paste0('rptDate=',year_date_series[1]))
      cost_and_income_list[1,1]<-fund_code[j]
      cost_and_income_list[1,2]<-as.character(year_date_series[1])
      # ���걨���ݰ������껯���õ��껯������ɱ�����ֵ
      cost_and_income_list[1,3]<-(cost_and_income$Data$PRT_BUYSTOCKCOST+cost_and_income$Data$PRT_SELLSTOCKINCOME)/2/(interval_days/365)
      cost_and_income_list[1,4]<-substr(year_date_series[1],1,4)
      
      if(length(year_date_series)>=2){
        for(i in 2:length(year_date_series)){
          cost_and_income<-w.wss(fund_code[j],'prt_buystockcost,prt_sellstockincome','unit=1',paste0('rptDate=',year_date_series[i]))
          cost_and_income_list[i,1]<-fund_code[j]
          cost_and_income_list[i,2]<-as.character(year_date_series[i])
          cost_and_income_list[i,3]<-(cost_and_income$Data$PRT_BUYSTOCKCOST+cost_and_income$Data$PRT_SELLSTOCKINCOME)/2
          cost_and_income_list[i,4]<-as.numeric(substr(year_date_series[i],1,4))
        }
      }
      colnames(cost_and_income_list)<-c("fund_code","date","average_cost_and_income","year")
      
      for(k in 1:length(quarter_date_series)){
        stock_value<-w.wss(fund_code[j],'prt_fundnetasset_total','unit=1',paste0('rptDate=',quarter_date_series[k]))$Data$PRT_FUNDNETASSET_TOTAL
        if(stock_value!='NaN'){
          date<-as.character(quarter_date_series[k])
          year<-as.numeric(substr(quarter_date_series[k],1,4))
          stock_value_temp<-data.frame(matrix(c(date,stock_value,year),ncol=3))
          stock_value_quarter<-rbind(stock_value_quarter,stock_value_temp)
        }
      }
      colnames(stock_value_quarter)<-c("date","stock_value","year")
      
      # �������ƽ��ֵ,�õ���ĸ
      stock_value_year<-aggregate(as.numeric(stock_value_quarter$stock_value),list(stock_value_quarter$year),FUN=mean)
      colnames(stock_value_year)<-c("year","stock_value")
      
      # �ѷ��ӷ�ĸ����ֵ�����merge
      merge_result<-merge(cost_and_income_list,stock_value_year,by=intersect(names(cost_and_income_list), names(stock_value_year)))
      merge_result$turnover_rate<-merge_result$average_cost_and_income/merge_result$stock_value
    }
    
    # ��������ղ����ڽӹ��գ����������Ǻ�����ֵĲ�Ʒ����һ�������ͳɱ�����Ҫʹ�ã��걨����-���걨���ݣ�*2������
    else{
      # ��ȡ�ӹ��պ�ĵ�һ�����걨���ڣ�������ɱ�����
      half_year_date<-w.tdays(manager_start_date,"","Days=Alldays;Period=S")$Data$DATETIME[1]
      cost_and_income_half_year<-w.wss(fund_code[j],'prt_buystockcost,prt_sellstockincome','unit=1',paste0('rptDate=',half_year_date))

      cost_and_income<-w.wss(fund_code[j],'prt_buystockcost,prt_sellstockincome','unit=1',paste0('rptDate=',year_date_series[1]))
      cost_and_income_list[1,1]<-fund_code[j]
      cost_and_income_list[1,2]<-as.character(year_date_series[1])
      # ��������ɱ�ʱ��2*���걨-���걨���õ��껯������ɱ�����ֵ
      cost_and_income_list[1,3]<-(cost_and_income$Data$PRT_BUYSTOCKCOST-cost_and_income_half_year$Data$PRT_BUYSTOCKCOST)
      +(cost_and_income$Data$PRT_SELLSTOCKINCOME-cost_and_income_half_year$Data$PRT_SELLSTOCKINCOME)
      cost_and_income_list[1,4]<-substr(year_date_series[1],1,4)
      
      # �ų�ĳЩ��Ʒֻ��һ����ȱ����ڵ����
      if(length(year_date_series)>=2){
        for(i in 2:length(year_date_series)){
          
          cost_and_income<-w.wss(fund_code[j],'prt_buystockcost,prt_sellstockincome','unit=1',paste0('rptDate=',year_date_series[i]))
          cost_and_income_list[i,1]<-fund_code[j]
          cost_and_income_list[i,2]<-as.character(year_date_series[i])
          cost_and_income_list[i,3]<-(cost_and_income$Data$PRT_BUYSTOCKCOST+cost_and_income$Data$PRT_SELLSTOCKINCOME)/2
          cost_and_income_list[i,4]<-substr(year_date_series[i],1,4)
        }
      }
      colnames(cost_and_income_list)<-c("fund_code","date","average_cost_and_income","year")
    }
    
    # ���ĸ������ƽ���ʲ���ֵ��
    stock_value_quarter<-data.frame(matrix(NA, ncol=3, nrow = 0))
    for(k in 1:length(quarter_date_series)){
      stock_value<-w.wss(fund_code[j],'prt_fundnetasset_total','unit=1',
                         paste0('rptDate=',quarter_date_series[k]))$Data$PRT_FUNDNETASSET_TOTAL
      # �ų�ĳЩ��Ʒ��������û����¶����������û���ʲ���ֵ���ݵ����
      if(stock_value!='NaN'){
        date<-as.character(quarter_date_series[k])
        year<-substr(quarter_date_series[k],1,4)
        stock_value_temp<-data.frame(matrix(c(date,stock_value,year),ncol=3))
        stock_value_quarter<-rbind(stock_value_quarter,stock_value_temp)
      }
    }
    colnames(stock_value_quarter)<-c("date","stock_value","year")
    
    # �����ʲ���ֵ���ݣ��������ƽ��ֵ,�õ���ĸ
    stock_value_year<-aggregate(as.numeric(stock_value_quarter$stock_value),list(stock_value_quarter$year),mean)
    colnames(stock_value_year)<-c("year","stock_value")
    
    # �ѷ��ӷ�ĸ����ֵ�����merge�����������
    merge_result<-merge(cost_and_income_list,stock_value_year,by=intersect(names(cost_and_income_list), names(stock_value_year)))
    merge_result$turnover_rate<-merge_result$average_cost_and_income/merge_result$stock_value
    
  }
  turnover_rate_result<-rbind(turnover_rate_result,merge_result)
}

write.csv(turnover_rate_result, "turnover_rate_result.csv")

t2<-proc.time()
t<-t2-t1
print(paste0('Total running time��',t[3][[1]],'s'))

