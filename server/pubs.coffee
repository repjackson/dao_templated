# Meteor.publish 'user_sent', (username)->
#     Docs.find {
#         model:'transfer'
#         _author_id: user._id
#     }, 
#         limit:100    
# Meteor.publish 'user_subscribed_to', (username)->
#         subscribed_user_ids:$in:[Meteor.userId()]
    
        
# Meteor.publish 'user_subscribed_by', (username)->
#         _id:$in: user.subscribed_user_ids
    
# Meteor.publish 'model_docs', (model)->
#     Docs.find {  
#         model:model
#     }, limit:100
    
# Meteor.publish 'transfers', (
#     username
#     direction
#     picked_tags
#     picked_authors
#     picked_targets
#     picked_timestamp_tags
#     picked_location_tags
#     filter=null
#     sort_key='_timestamp'
#     sort_direction=-1
#     )->
        
#     match = {model:'transfer'}
    
#     if filter is 'now'
#         now = Date.now()
#         gap = 60*60*1000
#         hour_ago = now-gap
#         match._timestamp = $gte:hour_ago
#     else if filter is 'today'
#         now = Date.now()
#         gap = 60*60*1000*24
#         day_ago = now-gap
#         match._timestamp = $gte:day_ago
    
#     if picked_tags.length > 0 then match.tags = $all:picked_tags 
#     if picked_location_tags.length > 0 then match.location_tags = $all:picked_location_tags 
#     if picked_timestamp_tags.length > 0 then match._timestamp_tags = $all:picked_timestamp_tags 
#     if picked_authors.length > 0 then match._author_username = $all:picked_authors 
#     if picked_targets.length > 0 then match.target_username = $all:picked_targets 
    
#     if username
#         if direction is 'sent'
#             match._author_id = user._id
#         if direction is 'received'
#             match.target_id = user._id

    
#     Docs.find match,
#         limit:20  
#         sort:
#             "#{sort_key}":sort_direction
        



# Meteor.publish 'today_leaderboard', ()->
#         total_sent_day: 
#             $exists:true
#     },{
#         sort:
#             total_sent_day:-1
#     })
    
    
# Meteor.methods
#     topup: (username)->
#         Docs.insert
#             model:'topup'
#             amount:10
#             _author_username:Meteor.user().username
            
# Meteor.publish 'user_topups', (username)->
#     Docs.find 
#         model:'topup'
#         _author_username:username
    
# Meteor.publish 'transfer_tags', (
#     username
#     direction
#     picked_tags
#     picked_authors
#     picked_targets
#     picked_timestamp_tags
#     picked_location_tags
#     # title_filter=null
#     filter=null
#     sort_key='_timestamp'
#     sort_direction=-1
#     )->
#     self = @
    
    
#     # match = {}
#     match = {}
#     match.model = 'transfer'
    
#     if filter is 'now'
#         now = Date.now()
#         gap = 60*60*1000
#         hour_ago = now-gap
#         match._timestamp = $gte:hour_ago
#     else if filter is 'today'
#         now = Date.now()
#         gap = 60*60*24*1000
#         day_ago = now-gap
#         match._timestamp = $gte:day_ago

    
#     if username
#         if direction is 'sent'
#             match._author_id = user._id
#         if direction is 'received'
#             match.target_id = user._id

    
#     if picked_tags.length > 0 then match.tags = $all:picked_tags 

#     if picked_location_tags.length > 0 then match.location_tags = $all:picked_location_tags 
#     if picked_timestamp_tags.length > 0 then match._timestamp_tags = $all:picked_timestamp_tags 
#     if picked_authors.length > 0 then match._author_username = $all:picked_authors 
#     if picked_targets.length > 0 then match.target_username = $all:picked_targets 



#     # if title_filter and title_filter.length > 1
#     #     match.title = {$regex:title_filter, $options:'i'}

#     result_count = Docs.find(match).count()

#     tag_cloud = Docs.aggregate [
#         { $match: match }
#         { $project: "tags": 1 }
#         { $unwind: "$tags" }
#         { $group: _id: "$tags", count: $sum: 1 }
#         { $match: _id: $nin: picked_tags }
#         { $match: count: $lt: result_count }
#         # { $match: _id: {$regex:"#{product_query}", $options: 'i'} }
#         { $sort: count: -1, _id: 1 }
#         { $limit: 10 }
#         { $project: _id: 0, title: '$_id', count: 1 }
#     ], {
#         allowDiskUse: true
#     }
    
#     tag_cloud.forEach (tag, i) =>
#         self.added 'results', Random.id(),
#             title: tag.title
#             count: tag.count
#             model:'tag'
#             direction:direction
#             # index: i
            
            
#     location_cloud = Docs.aggregate [
#         { $match: match }
#         { $project: "location_tags": 1 }
#         { $unwind: "$location_tags" }
#         { $group: _id: "$location_tags", count: $sum: 1 }
#         { $match: _id: $nin: picked_location_tags }
#         { $match: count: $lt: result_count }
#         # { $match: _id: {$regex:"#{product_query}", $options: 'i'} }
#         { $sort: count: -1, _id: 1 }
#         { $limit: 10 }
#         { $project: _id: 0, title: '$_id', count: 1 }
#     ], {
#         allowDiskUse: true
#     }
    
#     location_cloud.forEach (tag, i) =>
#         self.added 'results', Random.id(),
#             title: tag.title
#             count: tag.count
#             model:'location_tag'
#             # index: i
            
#     target_cloud = Docs.aggregate [
#         { $match: match }
#         { $project: "target_username": 1 }
#         { $unwind: "$target_username" }
#         { $group: _id: "$target_username", count: $sum: 1 }
#         { $match: _id: $nin: picked_targets }
#         { $match: count: $lt: result_count }
#         # { $match: _id: {$regex:"#{product_query}", $options: 'i'} }
#         { $sort: count: -1, _id: 1 }
#         { $limit: 10 }
#         { $project: _id: 0, title: '$_id', count: 1 }
#     ], {
#         allowDiskUse: true
#     }
    
#     target_cloud.forEach (tag, i) =>
#         self.added 'results', Random.id(),
#             title: tag.title
#             count: tag.count
#             model:'target_tag'
#             # index: i
            
            
#     author_cloud = Docs.aggregate [
#         { $match: match }
#         { $project: "_author_username": 1 }
#         { $unwind: "$_author_username" }
#         { $group: _id: "$_author_username", count: $sum: 1 }
#         { $match: _id: $nin: picked_authors }
#         { $match: count: $lt: result_count }
#         # { $match: _id: {$regex:"#{product_query}", $options: 'i'} }
#         { $sort: count: -1, _id: 1 }
#         { $limit: 10 }
#         { $project: _id: 0, title: '$_id', count: 1 }
#     ], {
#         allowDiskUse: true
#     }
    
#     author_cloud.forEach (tag, i) =>
#         self.added 'results', Random.id(),
#             title: tag.title
#             count: tag.count
#             model:'author_tag'
#             # index: i
            
#     # from_cloud = Docs.aggregate [
#     #     { $match: match }
#     #     { $project: "_author_username": 1 }
#     #     { $unwind: "$_author_username" }
#     #     { $group: _id: "$_author_username", count: $sum: 1 }
#     #     { $match: _id: $nin: picked_authors }
#     #     { $match: count: $lt: result_count }
#     #     # { $match: _id: {$regex:"#{product_query}", $options: 'i'} }
#     #     { $sort: count: -1, _id: 1 }
#     #     { $limit: 10 }
#     #     { $project: _id: 0, title: '$_id', count: 1 }
#     # ], {
#     #     allowDiskUse: true
#     # }
    
#     # tag_cloud.forEach (tag, i) =>
#     #     self.added 'results', Random.id(),
#     #         title: tag.title
#     #         count: tag.count
#     #         model:'from'
#     #         # index: i

#     self.ready()
    
        
        
        
        
        
# Meteor.publish 'user_transfers', (username)->
#     Docs.find {
#         model:'transfer'
#         _author_id: user._id
#     }, 
#         limit:20
#         sort:_timestamp:-1
        
        
Meteor.publish 'doc_comments', (doc_id)->
    # console.log 'hi pubbing'
    Docs.find   
        model:'comment'
        parent_id:doc_id  
        
        
Meteor.publish 'doc_by_id', (doc_id)->
    Docs.find doc_id
# Meteor.publish 'target_from_transfer_id', (transfer_id)->
#     transfer = 
#         Docs.findOne transfer_id
    
Meteor.publish 'related_wiki_article', (doc_id)->
    post = Docs.findOne doc_id
    Docs.find 
        model:'wikipedia'
        title:post.title
Meteor.publish 'doc', (doc_id)->
    Docs.find doc_id
    
# Meteor.publish 'comments', (doc_id)->
#     # doc = Docs.findOne doc_id
#     Docs.find 
#         model:'comment'
#         parent_id:doc_id
    
    
# Meteor.publish 'me', ()->

# Meteor.publish 'user_from_username', (username)->


# Meteor.publish 'ref_doc', (tag)->
#     match = {}
#     match.model = 'transfer'
#     match.title = tag.title
#     found = 
#         Docs.findOne match
#     if found
#         Docs.find match
#     else 
#         match.title = null
#         match.tags = $in:[tag.title]
#         Docs.find match,
#             sort:views:1
            
# Meteor.publish 'flat_ref_doc', (title)->
#     # if title
#     Docs.find({
#         model:'transfer'
#         tags:$in:[title]
#         # title:title
#     }, 
#         fields:
#             title:1
#             model:1
#             # metadata:1
#             image_id:1
#             image_url:1
#         limit:1
#     )
#     # else 
#     #     Docs.find {
#     #         model:'transfer'
#     #         tags:$in:[title]
#     #     },
#     #         sort:views:1
#     #         limit:1
