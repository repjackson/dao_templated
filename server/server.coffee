Cloudinary.config
    cloud_name: 'facet'
    api_key: Meteor.settings.private.cloudinary_key
    api_secret: Meteor.settings.private.cloudinary_secret

Docs.allow
    # insert: (userId, doc) -> doc._author_id is userId
    insert: (userId, doc) -> true
    update: (userId, doc) ->
        true
        # if userId then true
        # if doc.model in ['calculator_doc','simulated_rental_item','healthclub_session']
        #     true
        # else if Meteor.user() and Meteor.user().roles and 'admin' in Meteor.user().roles
        #     true
        # else
        #     doc._author_id is userId
    # update: (userId, doc) -> doc._author_id is userId or 'admin' in Meteor.user().roles
    remove: (userId, doc) -> 
        userId
        # doc._author_id is userId or 'admin' in Meteor.user().roles
Meteor.users.allow
    # insert: (userId, doc) -> doc._author_id is userId
    insert: (userId, doc) -> true
    update: (userId, doc) ->
        true
        # if userId then true
        # if doc.model in ['calculator_doc','simulated_rental_item','healthclub_session']
        #     true
        # else if Meteor.user() and Meteor.user().roles and 'admin' in Meteor.user().roles
        #     true
        # else
        #     doc._author_id is userId
    # update: (userId, doc) -> doc._author_id is userId or 'admin' in Meteor.user().roles
    remove: (userId, doc) -> 
        userId
        # doc._author_id is userId or 'admin' in Meteor.user().roles






Meteor.publish 'transfer_tags', (
    username
    direction
    picked_tags
    title_filter
    )->
    self = @
    
    user = Meteor.users.findOne(username:username)
    
    # match = {}
    match = {}
    match.model = 'transfer'
    
    if direction is 'sent'
        match._author_id = user._id
    if direction is 'received'
        match.target_id = user._id

    
    if picked_tags.length > 0 then match.tags = $all:picked_tags 

    if title_filter and title_filter.length > 1
        match.title = {$regex:title_filter, $options:'i'}

    result_count = Docs.find(match).count()
    console.log 'transfer tag result count', result_count

    tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: picked_tags }
        { $match: count: $lt: result_count }
        # { $match: _id: {$regex:"#{product_query}", $options: 'i'} }
        { $sort: count: -1, _id: 1 }
        { $limit: 11 }
        { $project: _id: 0, title: '$_id', count: 1 }
    ], {
        allowDiskUse: true
    }
    
    tag_cloud.forEach (tag, i) =>
        self.added 'results', Random.id(),
            title: tag.title
            count: tag.count
            model:'tag'
            # category:key
            # index: i

    self.ready()
    
# Meteor.publish 'wiki_docs', (
#     picked_tags=[]
#     )->
#         Docs.find 
#             model:'wikipedia'
#             title:$in:picked_tags
# Meteor.publish 'ref_doc', (tag)->
#     match = {app:'bc'}
#     match.model = 'post'
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
#     # console.log title
#     if title
#         Docs.find({
#             model:'post'
#             app:'bc'
#             title:title
#         }, 
#             fields:
#                 title:1
#                 model:1
#                 app:1
#                 # metadata:1
#                 image_id:1
#                 image_url:1
#             limit:1
#         )
#     else 
#         Docs.find {
#             model:'post'
#             tags:$in:[title]
#             app:'bc'
#         },
#             sort:
#                 views:1
#             fields:
#                 title:1
#                 model:1
#                 app:1
#                 # metadata:1
#                 image_id:1
#                 image_url:1
#             limit:1
            
            
# Meteor.publish 'post_docs', (
#     picked_tags=[]
#     title_filter
#     )->

#     self = @
#     # match = {}
#     match = {app:'bc'}
#     match.model = 'post'
#     # match.group_id = Meteor.user().current_group_id
#     if title_filter and title_filter.length > 1
#         match.title = {$regex:title_filter, $options:'i'}
    
#     # if picked_tags.length > 0 then match.tags = $all:picked_tags 
#     if picked_tags.length > 0 then match.tags = $all:picked_tags 
#     Docs.find match, 
#         limit:10
#         fields:
#             title:1
#             model:1
#             tags:1
#             app:1
#             image_id:1
#             image_url:1
#             body:1
#         sort:
#             views:-1
            
            
