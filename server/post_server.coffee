Meteor.publish 'post_facets', (
    picked_tags
    title_filter
    )->
    self = @
    # match = {}
    match = {app:'bc'}
    match.model = 'post'
    # match.group_id = Meteor.user().current_group_id
    if picked_tags.length > 0 then match.tags = $all:picked_tags 
    console.log 'tags match', match

    if title_filter and title_filter.length > 1
        match.title = {$regex:title_filter, $options:'i'}

    tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: picked_tags }
        # { $match: _id: {$regex:"#{product_query}", $options: 'i'} }
        { $sort: count: -1, _id: 1 }
        { $limit: 20 }
        { $project: _id: 0, title: '$_id', count: 1 }
    ], {
        allowDiskUse: true
    }
    
    tag_cloud.forEach (tag, i) =>
        # console.log 'queried tag ', tag
        # console.log 'key', key
        self.added 'results', Random.id(),
            title: tag.title
            count: tag.count
            model:'post_tag'
            # category:key
            # index: i

    self.ready()
    
# Meteor.publish 'wiki_docs', (
#     picked_tags=[]
#     )->
#         Docs.find 
#             model:'wikipedia'
#             title:$in:picked_tags
Meteor.publish 'ref_doc', (tag)->
    # console.log 'wiki doc pub', tag
    Docs.find({
        model:'post'
        title:tag.title
    }, 
        fields:
            title:1
            model:1
            # metadata:1
            image_id:1
    )
Meteor.publish 'flat_ref_doc', (title)->
    console.log 'flat_ref doc', title
    Docs.find({
        model:'post'
        title:title
    }, 
        fields:
            title:1
            model:1
            app:1
            # metadata:1
            image_id:1
        limit:1
    )
Meteor.publish 'post_docs', (
    picked_tags=[]
    title_filter
    )->

    self = @
    # match = {}
    match = {app:'bc'}
    match.model = 'post'
    # match.group_id = Meteor.user().current_group_id
    if title_filter and title_filter.length > 1
        match.title = {$regex:title_filter, $options:'i'}
    
    if picked_tags.length > 0 then match.tags = $all:picked_tags 
    console.log match
    Docs.find match, 
        limit:10
        sort:
            _timestamp:-1