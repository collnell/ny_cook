library(stringr)
library(rvest)

nycook<-read_html("http://cooking.nytimes.com/68861692-nyt-cooking/3891782-our-50-most-popular-recipes-of-2016")
url<-"http://cooking.nytimes.com/68861692-nyt-cooking/3891782-our-50-most-popular-recipes-of-2016"
cook<-readLines(url)##read webpage
##pull url for weblinks
web_url<-'data-url=\"'
recipe_pages<-grep(web_url, cook[243:length(cook)], value=TRUE)##pull addys
recipe_id<-gsub(web_url, "", recipe_pages)%>% ##clean up link ids
  gsub(pattern='"',replacement= "")%>%
  str_trim(side="both")
recipe_id##looks good
##now write urls for each recipe
site_pre<-'http://cooking.nytimes.com'
site_post<-'?action=click&module=Collection+Page+Recipe+Card&region=Our+50+Most+Popular+Recipes+of+2016&pgType=collection&rank=1'
recipe_sites<-as.list(paste0(site_pre, recipe_id, site_post))
#recipe_sites
cook_sites<-data.frame(site = recipe_sites,id= recipe_id)
##now pull recipe data from each site
######################
##function that takes a nytimes recipe list and extracts all the ingredients for each recipe
##returns a df with the name of the recipe and ingredients found in each
##does some cleaning of ingredient names to match (imperfect)
##written for the top recipes of 2016, working on making universal
#params
#url = the url of the nytimes cooking website list
##currently incomplete
get_recipe<-function(url){
 ##use url to find the key of each recipe and make list called recipe_id
 ##find in url where the key is and how to split
  #
  nycook<-read_html("http://cooking.nytimes.com/68861692-nyt-cooking/3891782-our-50-most-popular-recipes-of-2016")
  url<-"http://cooking.nytimes.com/68861692-nyt-cooking/3891782-our-50-most-popular-recipes-of-2016"
  cook<-readLines(url)##read webpage
  
  ##pull url for weblinks
  web_url<-'data-url=\"'
  recipe_pages<-grep(web_url, cook[243:length(cook)], value=TRUE)##pull addys
  recipe_id<-gsub(web_url, "", recipe_pages)%>% ##clean up link ids
    gsub(pattern='"',replacement= "")%>%
    str_trim(side="both")
  
  recipe_ingredients=NULL #empty df for ingredient list
  ##then integrate in the for loop
}


####################################
recipe_ingredients=NULL ##empty df
##loop to pull ingredients from all recipes in list from nytimes
for (i in recipe_id){
  ##extract keys for each recipe and extract web text
  site_pre<-'http://cooking.nytimes.com'
  site_post<-'?action=click&module=Collection+Page+Recipe+Card&region=Our+50+Most+Popular+Recipes+of+2016&pgType=collection&rank=1'
  recipe_site<-paste0(site_pre, i, site_post)
  recipe<-readLines(recipe_site)
  #extract ingredients
  ing_pattern<-'<span class=\"ingredient-name\">'
  ing_list<-grep(ing_pattern, recipe[300:length(recipe)], value=TRUE)
  #clean ingredient
  ingredients<-gsub(ing_pattern, "", ing_list)%>%
    tolower()%>%
    gsub(pattern='</span>', replacement="")%>%
    gsub(pattern='<span>', replacement="")%>%
    gsub(pattern="\\,.*", replacement="")%>%
    gsub(pattern='[0-9]+', replacement='')%>%
    str_replace_all(pattern="[^[:alnum:]]", replacement=" ")
  rec_name<-gsub(i, pattern="^.*?\\-", replacement="") ##convert url to recipe name
  ##remove extra wordage
  measures<-c("teaspoon","two","ct","tablespoon","more","teaspoons","handful","ears ","stems of","sleeve","large","diced", "sprig","to taste","tablespoons"," can ","cup","pounds","pound","cups","stick","sticks","pint","quart","pinch","gallon","ounce","grams","ounces","gallons","quarts","pints","kg","mg","milliliters")
  adjectives<-c("young","good quality brine cured ","basic"," not quick cooking","hungarian ","italian","rib","like soom","liquid","seed","smooth","thick","cooked","grappa","crushed","use a food processor if you have one","from ","torn","stems","to ","coarse","at room temperature","heaping","optional","white","fleshed","chopped","loosely","small","ripe","yellow","boneless","squeezed","stalks","rich","prepared","about"," of "," or","mixed","slivered"," day "," old ","fine","rolled","raw ","wild"," and ","unsalted","ripe","bunch","firm","size","plus","head","neutral","cleaned","extra","very","sifted","branches","kosher","yellow","juice","zest","paste","clove","cloves","tender","leaves","large","fresh","sprigs","skinless","medium","small","diced","chopped","thick","slices","sliced","minced","packed","loosely","flaky","handful","crushed","roughly","pitted","finely","low sodium","whole","cold","hot","warm","toasted","roasted","grated","shredded","peeled","skinned","freshly","unsweetened","canned","dried","ground")
  ing_o <- as.character(sapply(ingredients, function(x) 
    gsub(paste(measures, collapse = '|'), '', x)))
  ing_only <- as.character(sapply(ing_o, function(x) 
    gsub(paste(adjectives, collapse = '|'), '', x)))
  ing_only<-gsub(ing_only, pattern="s ", replacement="")
  ing_only<-gsub(ing_only, pattern="  ", replacement=" ")
  ing_only<-gsub(ing_only, pattern="  ", replacement=" ")
  ing_only<-ing_only%>%str_trim(side="both")#clean whitespace
  ingreds<-data.frame(recipe = rep(rec_name,length(ing_only)), ingredient = ing_only)
  ingreds<-ingreds[!grepl("href", ingreds$ingredient),]
  recipe_ingredients=rbind(recipe_ingredients,ingreds)#return df
}
##look at results
length(unique(recipe_ingredients$recipe))
length(unique(recipe_ingredients$ingredient))
length(recipe_ingredients$ingredient)
ez<-recipe_ingredients
ez$ingredient<-as.character(ez$ingredient)
ez$ingredienty<-as.character(ifelse(grepl("olive oil", ez$ingredient), 'oliveoil',
                                    ifelse(grepl("salt black pepper", ez$ingredient), 'salt',
                                           ifelse(grepl("black pepper", ez$ingredient), 'blackpepper',
                                           ifelse(grepl("saltpepper", ez$ingredient), 'blackpepper',
                                                  ifelse(grepl("chicken", ez$ingredient), 'chicken',
                                                         ifelse(grepl("mushroom", ez$ingredient), 'mushroom',
                                                                ifelse(grepl("sugar", ez$ingredient), 'sugar',
                                                                       ifelse(grepl("toma", ez$ingredient), 'tomato',
                                                                              ifelse(grepl("bone in", ez$ingredient), "chicken",
                                                                                     ifelse(grepl("bacon", ez$ingredient), 'bacon',
                                    ifelse(grepl("lemon", ez$ingredient), 'lemon', 
                                           ifelse(grepl("bread", ez$ingredient), 'bread',
                                                  ifelse(grepl("butter", ez$ingredient), 'butter',
                                                    ifelse(grepl("butter", ez$ingredient), 'butter',
                                                           ifelse(grepl("stock", ez$ingredient), 'stock',
                                                                  ifelse(grepl("turmeric", ez$ingredient), 'turmeric',
                                                                         ifelse(grepl("thyme", ez$ingredient), 'thyme',
                                                                                (ifelse(grepl("tamarind", ez$ingredient), 'tamarind',
         ifelse(grepl("shrimp", ez$ingredient), 'shrimp',
                ifelse(grepl("saffron", ez$ingredient), 'saffron',
                       ifelse(grepl("red chile flakes", ez$ingredient), 'red pepper flakes',
                              ifelse(grepl("yogurt", ez$ingredient), 'yogurt',
                                     ifelse(grepl("carrot", ez$ingredient), 'carrot',
                                            ifelse(grepl("black pepper", ez$ingredient), 'black pepper',
                                                   ifelse(grepl("beef", ez$ingredient), 'beef',
                                                          ifelse(grepl("mustard", ez$ingredient), 'mustard', 
                                                                 ifelse(grepl("anchov", ez$ingredient), 'anchovies',
                                                                        ifelse(grepl("potato", ez$ingredient), 'potato',
                                                                               ifelse(grepl("mint", ez$ingredient), 'mint',
                                                                                      ifelse(grepl("chocolate", ez$ingredient), 'chocolate',
                                                                                             ifelse(grepl("cocoa", ez$ingredient), 'chocolate',
                                                                                                    ifelse(grepl("ecchiette", ez$ingredient), 'ecchiette',
                                                                                                           ifelse(grepl("egano", ez$ingredient), 'egano',
                                                                                                                  ifelse(grepl("cardamom", ez$ingredient), 'cardamom',
                                                                                                                         ifelse(grepl("gruyère", ez$ingredient), 'gruyère',
                                                                                                                                ifelse(grepl("jalapeño", ez$ingredient), 'jalapeño',
                                                                                                                                       ifelse(grepl("parmigiano", ez$ingredient), 'parmesan',
                                                                                                                                              ifelse(grepl("kale", ez$ingredient), 'kale',
                                                                                                                                                     ifelse(grepl("lime", ez$ingredient), 'lime',
                                                                                                                                                            ifelse(grepl("onion", ez$ingredient), 'onion',
                                                                                                                                                                   ifelse(grepl("tahini", ez$ingredient), 'tahini',
                                                                                                                                                                          ifelse(grepl("nutmeg", ez$ingredient), 'nutmeg',
                                                                                                                                                                                 ifelse(grepl("paprika", ez$ingredient), 'paprika',
                                                                                                                                                                                        ifelse(grepl("parmesan", ez$ingredient), 'parmesan',
                                                                                                                                                                                               ifelse(grepl("feta", ez$ingredient), 'feta',
                                                                                                                                                                                                      ifelse(grepl("flour", ez$ingredient), 'flour',
                                                                                                                         
                                                                 ez$ingredient))))))))))))))))))))))))))))))))))))))))))))))))


length(unique(ez$ingredienty))
##how many ingredients are in each recipe?
#ing_count<-ez%>%
 # group_by(recipe)%>%
  #summarize(n_ingredients = length(unique(ingredienty)), 
   #         ingredient_list= paste(ingredienty, collapse = ", "))
#View(ing_count)

##ingredient counts
df<-ez%>%
  group_by(ingredienty)%>%
  summarize(recipes_in = length(recipe))
View(df)
df_short<-filter(df, df$recipes_in>=4)
str(df_short)
ings<-df_short$ingredienty
ings
##make adjacency matrix
library(reshape2)
fd<-ez[,c("recipe","ingredienty")]
fd.melt<-melt(fd, id.vars=c("recipe"),na.rm=FALSE)
fd.melt<-filter(fd.melt, value %in% ings)
str(fd.melt)
trec_cast<-dcast(fd.melt, recipe~value,fill=0, drop=FALSE)

rec_wide<-trec_cast%>%select(-salt, -butter, -garlic, -oil, -blackpepper, -oliveoil)
str(rec_wide)
View(rec_wide)
###wide df- recipe x ingredients
recs<-rec_wide[,-1]
rownames(recs)<-rec_wide$recipe
rec<-as.matrix(recs)
###network data
##adjacency matrix
#by ingredients

ing_adj<-crossprod(rec)
View(ing_adj)##which ingredients are found in recipes together

##recipes similar to one another
rec_adj<-crossprod(t(rec))##recipes with simialr ingredients

##make network visualization
library(igraph)
library(network)
library(sna)
library(ndtv)
library(visNetwork)
str(net3)
net3<-graph_from_adjacency_matrix(ing_adj, diag=FALSE, mode="undirected", weighted=TRUE)
net <- simplify(net3, remove.multiple = T, remove.loops = T)
E(net)$width<- 2+E(net)$weight/5

str(net)
plot(net, edge.arrow.size=.2, edge.color="orange",
     vertex.color="orange", vertex.frame.color="#ffffff",
     vertex.label=V(net3)$recipe, vertex.label.color="black")
plot(net, vertex.label=V(net3)$recipe, edge.color="lightseagreen",
     vertex.color="orange", vertex.frame.color="#ffffff",
     vertex.label.font=2, vertex.label.color="black",
     vertex.label.cex=1, edge.color="gray85",
     layout=layout_with_lgl, edge.width=E(net)$weight)

install.packages('ggplot2')
library(ggplot2)
library(GGally)

devtools::install_github("briatte/ggnet", force=TRUE)
library(ggnet2)
library(network)
library(sna)
library(ggplot2)
?rgraph
?ggnet2
??ggnet2
