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

Meteor.methods
    log_view: (doc_id)->
        Docs.update doc_id,
            $inc:views:1


Meteor.publish 'parent_doc', (doc_id)->
    found = Docs.findOne doc_id
    Docs.find
        _id:found.parent_id
        
Meteor.publish 'all_users', (doc_id)->
    Meteor.users.find()

        
Meteor.publish 'doc_by_id', (doc_id)->
    Docs.find doc_id
Meteor.publish 'doc', (doc_id)->
    Docs.find doc_id
Meteor.publish 'model_docs', (model)->
    Docs.find {
        model:model
        app:'bc'
    }, limit:20

Meteor.publish 'me', ()->
    Meteor.users.find Meteor.userId()

Meteor.publish 'user_from_username', (username)->
    Meteor.users.find username:username

Meteor.publish 'user_from_id', (user_id)->
    Meteor.users.find user_id

Meteor.publish 'author_from_doc_id', (doc_id)->
    doc = Docs.findOne doc_id
    if doc and doc._author_id
        Meteor.users.find doc._author_id




# Meteor.publish 'post_facets', (
#     picked_tags
#     title_filter
#     )->
#     self = @
#     # match = {}
#     match = {app:'bc'}
#     match.model = 'post'
#     if picked_tags.length > 0 then match.tags = $all:picked_tags 

#     if title_filter and title_filter.length > 1
#         match.title = {$regex:title_filter, $options:'i'}

#     result_count = Docs.find(match).count()
#     console.log result_count

#     tag_cloud = Docs.aggregate [
#         { $match: match }
#         { $project: "tags": 1 }
#         { $unwind: "$tags" }
#         { $group: _id: "$tags", count: $sum: 1 }
#         { $match: _id: $nin: picked_tags }
#         { $match: count: $lt: result_count }
#         # { $match: _id: {$regex:"#{product_query}", $options: 'i'} }
#         { $sort: count: -1, _id: 1 }
#         { $limit: 11 }
#         { $project: _id: 0, title: '$_id', count: 1 }
#     ], {
#         allowDiskUse: true
#     }
    
#     tag_cloud.forEach (tag, i) =>
#         self.added 'results', Random.id(),
#             title: tag.title
#             count: tag.count
#             model:'post_tag'
#             # category:key
#             # index: i

#     self.ready()
    
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
            
            


Meteor.methods
    # calc_request_stats: ->
    #     res = Docs.aggregate [
    #         { $group:
    #             _id: "$item",
    #             avgAmount: { $avg: { $multiply: [ "$price", "$quantity" ] } },
    #             avgQuantity: { $avg: "$quantity" }
    #          }
    #     ]
    #     console.log res

    lookup_user: (username_query, role_filter)->
        found_users =
            Meteor.users.find({
                username: {$regex:"#{username_query}", $options: 'i'}
                # roles:$in:[role_filter]
                }).fetch()
        found_users



    calc_user_points: (username)->
        user = Meteor.users.findOne username:username
        # match = {}
        # match._author_username = username
       
       
        # match.model = 'work'
        # match.task_points = $exists:true
        # point_credit_total = 0
        
        
        # point_credit_docs = Docs.find(match).fetch()
        # for point_doc in point_credit_docs 
        #     point_credit_total += point_doc.task_points
            
        # console.log 'work credit total', point_credit_total
        
        # topup_match = {}
        # topup_match.model = 'topup'
        # topup_match.topup_amount = $exists:true
        # point_topup_total = 0
        
        # point_topup_docs = Docs.find(topup_match).fetch()
        # for topup_doc in point_topup_docs 
        #     # console.log topup_doc.topup_amount
        #     if topup_doc.topup_amount
        #         point_topup_total += parseInt(topup_doc.topup_amount)
            
        # console.log 'topup credit total', point_topup_total
                        # 
        # total_bought_credit_rank = Meteor.users.find(total_bought_credits:$gt:parseInt(point_topup_total)).count()
        # # console.log 'total earned credit rank', total_earned_credit_rank
        # Meteor.users.update user._id, 
        #     $set:total_bought_credit_rank:total_bought_credit_rank+1

        # res = Docs.aggregate [
        #     { $match: match }
        #     # { $project: tags: 1 }
        #     { $group:
        #         _id: "$item",
        #         point_total: { $sum: "$task_points" },
        #         # avgAmount: { $avg: { $multiply: [ "$price", "$quantity" ] } },
        #         # avgQuantity: { $avg: "$quantity" }
        #     }
        #     { $project: _id: 0, point_total: 1 }
        # ]
        # console.log res.toArray()
        # user = Meteor.users.findOne current_order._author_id
        # console.log 'user points', user.points
        # orders = 
        #     Docs.find 
        #         model:'order'
        #         _author_id:user._id
                
        # total_debits = 0
        # total_calories_consumed = 0
        # for order in orders.fetch() 
        #     # console.log 'order purchase amount', order.purchase_amount
        #     if order.purchase_amount
        #         total_debits += parseInt(order.purchase_amount)
        #     product = Docs.findOne _id:order.product_id
        #     if product
        #         if product.calories
        #             # console.log 'calories added', product.calories
        #             total_calories_consumed += parseInt(product.calories)
        # console.log 'total debits', total_debits
        # console.log 'total credits', point_credit_total
        # final_calculated_current_points = point_credit_total - total_debits + point_topup_total
        
        total_received = 0
        received_docs = 
            Docs.find
                model:'transfer'
                target_id:user._id
        
        for transfer in received_docs.fetch()
            console.log transfer
            
            if transfer.amount
                total_received += transfer.amount 
        console.log 'total received points', total_received
        
        
        total_sent = 0
        sent_docs = 
            Docs.find
                model:'transfer'
                _author_id:user._id
        
        for transfer in sent_docs.fetch()
            # console.log transfer.amount
            if transfer.amount
                total_sent += transfer.amount 
        console.log 'total sent points', total_sent
        final_calculated_current_points = total_received - total_sent
        
        # console.log 'total current points', final_calculated_current_points
        # if final_calculated_current_points
        #     Meteor.users.update user._id,
        #         $set:
        #             points: final_calculated_current_points
        #     current_point_rank = Meteor.users.find(points:$gt:parseInt(final_calculated_current_points)).count()
        #     # console.log 'amount more ranked', current_point_rank
        #     Meteor.users.update user._id, 
        #         $set:point_rank:current_point_rank+1

        # calculated_total_earned_credits = point_credit_total
        # calculated_total_bought_credits = point_topup_total

                # 
        # total_earned_credit_rank = Meteor.users.find(total_earned_credits:$gt:parseInt(calculated_total_earned_credits)).count()
        # console.log 'total earned credit rank', total_earned_credit_rank
        # Meteor.users.update user._id, 
        #     $set:total_earned_credit_rank:total_earned_credit_rank+1

        
        # calculated_total_credits = point_credit_total + point_topup_total
        
        # console.log 'total current points', final_calculated_current_points
        # if final_calculated_current_points
        Meteor.users.update user._id,
            $set:
                points: final_calculated_current_points
                # total_earned_credits: point_credit_total
                # total_bought_credits: point_topup_total
                # total_credits: point_credit_total + point_topup_total
                # total_calories_consumed: total_calories_consumed
        # amount = Meteor.users.find(points:$gt:parseInt(final_calculated_current_points)).count()
        # # console.log 'amount more ranked', amount
        # Meteor.users.update user._id, 
        #     $set:point_rank:amount


        # res.forEach (tag, i) =>
        #     console.log tag
        #     Meteor.users.update user._id, 
        #         $set:points: tag.point_total
        #     # self.added 'tags', Random.id(),
        #     #     name: tag.name
        #     #     count: tag.count
        #     #     index: i
        
Meteor.methods
    insert_doc: (doc)->
        # console.log 'inserting object', doc
        # Docs.insert 
        #     doc
        
        if Meteor.userId()
            doc._author_id = Meteor.userId()
            doc._author_username = Meteor.user().username
            if Meteor.user().current_group_id
                doc.group_id = Meteor.user().current_group_id
        
        timestamp = Date.now()
        doc._timestamp = timestamp
        doc._timestamp_long = moment(timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")
        date = moment(timestamp).format('Do')
        weekdaynum = moment(timestamp).isoWeekday()
        weekday = moment().isoWeekday(weekdaynum).format('dddd')
    
        hour = moment(timestamp).format('h')
        minute = moment(timestamp).format('m')
        ap = moment(timestamp).format('a')
        month = moment(timestamp).format('MMMM')
        year = moment(timestamp).format('YYYY')
    
        # date_array = [ap, "hour #{hour}", "min #{minute}", weekday, month, date, year]
        date_array = [ap, weekday, month, date, year]
        if _
            date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
            # date_array = _.each(date_array, (el)-> console.log(typeof el))
            # console.log date_array
            doc._timestamp_tags = date_array
    
        doc.app = 'bc'
        # doc.points = 0
        # doc.downvoters = []
        # doc.upvoters = []
        # return
        new_id = Docs.insert doc
        console.log 'new id', new_id
        new_id
        


            