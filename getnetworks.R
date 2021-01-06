library(rtweet)
library(dplyr)
library(data.table)
library(lubridate)
library(mongolite)
library(redux)
library(jsonlite)
getuser<-function(id,m){
  q<-toJSON(list(user_id=id))
  dt<-m$find(q)
  if(nrow(dt)==0){
    dt<-try(lookup_users(id, token=token))
    if (class(dt)=='try_error'){
      return(NULL)
      } else {
      musers$insert(dt)
      return(dt)
    }
  }
}
mongoid<-Sys.getenv('mongo_user')
mongopass<-Sys.getenv('mongo_pass')
remotehost<-Sys.getenv('remote_host')
r <- redux::hiredis(config=list(host=remotehost, port=6379))
URI = sprintf("mongodb://%s:%s@%s:27017", mongoid, mongopass, remotehost)
musers<-mongo('users',db='twitter',url = URI)
mnetwork<-mongo('network',db='twitter',url = URI)
tokpath<-Sys.getenv("TWITTER_PAT")
message(tokpath)
token<-readRDS(tokpath)
while (TRUE){
  
  if (r$LLEN('users')>0){
      message("Found an ID")
    userdt<-r$LPOP("users")
    userdt<-string_to_object(userdt)
    degrees<-userdt$degrees
    if(degrees==0) {
      userdt<-NULL
      next
    }
    degrees<-degrees-1
    usern<-userdt$user_id
    userdt<-getuser(usern,musers)
    friends<-get_friends(users=as.character(usern),retryonratelimit =TRUE, token=token)
    setDT(friends)
    colnames(friends)<-c('user_id','follows')
    mnetwork$insert(friends)
    friendlist<-friends$follows
    frienddt<-lapply(friendlist, function(x){getuser(x,musers)})
    redis<-redis
    d<-data.frame(user_id=friendlist, degrees=rep(degrees,length(friendlist)))
    cmds<-lapply(1:nrow(d), function(x) redis$LPUSH('users',object_to_string(d[x,])))
    r$pipeline(.commands=cmds)
    followers<-get_followers(user = usern,retryonratelimit = TRUE, token=token)
    setDT(followers)
    d<-data.frame(user_id=followers$user_id, degrees=rep(degrees,length(followers$user_id)))
    cmds<-lapply(1:nrow(d), function(x) redis$LPUSH('users',object_to_string(d[x,])))
    r$pipeline(.commands=cmds)
    followers[,follows:=usern]
    followerdt<-lapply(followers$user_id, function(x){getuser(x, musers)})
    mnetwork$insert(followers)
    Sys.sleep(60+sample(0:60,1))
  } 
}



