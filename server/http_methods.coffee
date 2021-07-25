# request = require('request')
# rp = require('request-promise');
# Meteor.methods
#     search_reddit: (query)->
#         # @unblock()
#         # if subreddit 
#         #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
#         # else
#         url = "http://reddit.com/search.json?q=#{query}&limit=100&include_facets=true&raw_json=1"
#         # url = "https://www.reddit.com/user/hernannadal/about.json"
#         options = {
#             url: url
#             headers: 
#                 # 'accept-encoding': 'gzip'
#                 "User-Agent": "web:com.dao.af:v1.2.3 (by /u/dao-af)"
#             # gzip: true
#         }
#         console.log 'searching', query
#         rp(options)
#             .then(Meteor.bindEnvironment((res)->
#                 parsed = JSON.parse(res)
#                 # if parsed.data.dist > 1
#                 _.each(parsed.data.children, (item)=>
#                     # unless item.domain is "OneWordBan"
#                     data = item.data
#                     len = 200
#                     added_tags = [query]
#                     # added_tags.push data.domain.toLowerCase()
#                     # added_tags.push data.subreddit.toLowerCase()
#                     # added_tags.push data.title.toLowerCase()
#                     # added_tags.push data.author.toLowerCase()
#                     added_tags = _.flatten(added_tags)
#                     existing = Docs.findOne 
#                         model:'rpost'
#                         url:data.url
#                         subreddit:data.subreddit
#                     # if existing
#                     #     # if Meteor.isDevelopment
#                     #     # if typeof(existing.tags) is 'string'
#                     #     #     Doc.update
#                     #     #         $unset: tags: 1
#                     #     Docs.update existing._id,
#                     #         $addToSet: tags: $each: added_tags
#                     #         $set:
#                     #             url: data.url
#                     #             domain: data.domain
#                     #             selftext: data.selftext
#                     #             selftext_html: data.selftext_html
#                     #             comment_count: data.num_comments
#                     #             permalink: data.permalink
#                     #             body: data.body
#                     #             thumbnail: data.thumbnail
#                     #             is_reddit_media_domain: data.is_reddit_media_domain
#                     #             link_title: data.link_title
#                     #             body_html: data.body_html
#                     #             ups: data.ups
#                     #             title: data.title
#                     #             created_utc: data.created_utc
#                     #             # html:data.media.oembed.html    
#                     #         $unset:
#                     #             data:1
#                     #             # watson:1
#                         # if data.media
#                         #     if data.media.oembed
#                         #         if data.media.oembed.html
#                         #             Docs.update existing._id,
#                         #                 $set:
#                         #                     html: data.media.oembed.html

#                             # $set:data:data

#                         # Meteor.call 'get_reddit_post', existing._id, data.id, (err,res)->
#                     unless existing
#                         reddit_post =
#                             reddit_id: data.id
#                             url: data.url
#                             domain: data.domain
#                             comment_count: data.num_comments
#                             thumbnail: data.thumbnail
#                             body_html: data.body_html
#                             permalink: data.permalink
#                             selftext: data.selftext
#                             selftext_html: data.selftext_html
#                             is_reddit_media_domain: data.is_reddit_media_domain
#                             ups: data.ups
#                             title: data.title
#                             link_title: data.link_title
#                             created_utc: data.created_utc
#                             # html:data.media.oembed.html    
#                             subreddit: data.subreddit
#                             # selftext: false
#                             # thumbnail: false
#                             tags: added_tags
#                             model:'rpost'
#                             # source:'reddit'
#                             # data:data
#                         if data.media
#                             if data.media.oembed
#                                 if data.media.oembed.html
#                                     reddit_post.html = data.media.oembed.html
#                         new_reddit_post_id = Docs.insert reddit_post
#                         # if Meteor.isDevelopment
#                         # Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
#                 Meteor.call 'call_wiki', query, ->        
#                 )
#             )).catch((err)->
#             )

   



Meteor.methods
    call_wiki: (query)->
        # term = query.split(' ').join('_')
        # term = query[0]
        # @unblock()
        term = query
        # HTTP.get "https://en.wikipedia.org/wiki/#{term}",(err,response)=>
        HTTP.get "https://en.wikipedia.org/w/api.php?action=opensearch&generator=searchformat=json&search=#{term}",(err,response)=>
            unless err
                for term,i in response.data[1]
                    url = response.data[3][i]
    
    
                    found_doc =
                        Docs.findOne
                            url: url
                            model:'wikipedia'
                            title:query
                    if found_doc
                        console.log 'found wiki doc', found_doc
                        # Docs.update found_doc._id,
                        #     # $pull:
                        #     #     tags:'wikipedia'
                        #     $set:
                        #         title:found_doc.title.toLowerCase()
                        unless found_doc.metadata
                            Meteor.call 'call_watson', found_doc._id, 'url','url', ->
                    else
                        new_wiki_id = Docs.insert
                            title:term.toLowerCase()
                            tags:[term.toLowerCase()]
                            source: 'wikipedia'
                            model:'wikipedia'
                            # ups: 1
                            url:url
                        console.log 'new wiki doc', term
                        Meteor.call 'call_watson', new_wiki_id, 'url','url', ->