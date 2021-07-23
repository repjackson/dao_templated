Meteor.publish 'post_facets', (
    picked_tags
    title_filter
    # picked_authors=[]
    # picked_tasks=[]
    # picked_locations=[]
    # picked_timestamp_tags=[]
    # view_videos
    # view_images
    # view_events
    # view_tasks
    # view_locations
    # view_food
    # sort_key
    # sort_direction

    )->
    # console.log 'dummy', dummy
    # console.log 'query', query
    # console.log 'picked staff', picked_authors

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
        { $limit: 25 }
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
Meteor.publish 'wiki_doc', (tag)->
    # console.log 'wiki doc pub', tag.title
    Docs.find({
        model:'wikipedia'
        title:tag.title
    }, 
        fields:
            title:1
            model:1
            metadata:1
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
        limit:20
        sort:
            _timestamp:-1