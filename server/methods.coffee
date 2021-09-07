Meteor.methods 
    remove_friend_by_username: (username)->
        found = Meteor.users.findOne username:username
        Meteor.users.update Meteor.userId(),
            $pull:
                friend_ids:found._id
                friend_usernames:found.username
    
    add_friend_by_username: (username)->
        found = Meteor.users.findOne username:username
        if found 
            Meteor.users.update Meteor.userId(),
                $addToSet:
                    friend_ids:found._id
                    friend_usernames:found.username
    log_profile_view: (username)->
        found = Meteor.users.findOne username:username
        unless Meteor.user() and Meteor.user().username is username
            Meteor.users.update found._id, 
                $inc:profile_views:1
    search_by_username: (username)->
        found = Meteor.users.findOne 
            username:username

        
    insert_doc: (doc)->
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
            doc._timestamp_tags = date_array
    
        doc.app = 'bc'
        # doc.points = 0
        # doc.downvoters = []
        # doc.upvoters = []
        # return
        new_id = Docs.insert doc
        new_id
        

            
    # calc_request_stats: ->
    #     res = Docs.aggregate [
    #         { $group:
    #             _id: "$item",
    #             avgAmount: { $avg: { $multiply: [ "$price", "$quantity" ] } },
    #             avgQuantity: { $avg: "$quantity" }
    #          }
    #     ]

    lookup_user: (username_query)->
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
            
        
        # topup_match = {}
        # topup_match.model = 'topup'
        # topup_match.topup_amount = $exists:true
        # point_topup_total = 0
        
        # point_topup_docs = Docs.find(topup_match).fetch()
        # for topup_doc in point_topup_docs 
        #     if topup_doc.topup_amount
        #         point_topup_total += parseInt(topup_doc.topup_amount)
            
                        # 
        # total_bought_credit_rank = Meteor.users.find(total_bought_credits:$gt:parseInt(point_topup_total)).count()
        # Meteor.users.update user._id, 
        #     $set:total_bought_credit_rank:total_bought_credit_rank+1

        # res = Docs.aggregate [
        #     { $match: match }
        #     # { $project: tags: 1 }
        #     { $group:
        #         _id: "$item",
        #         point_total: { $sum: "$amount" },
        #         # avgAmount: { $avg: { $multiply: [ "$price", "$quantity" ] } },
        #         # avgQuantity: { $avg: "$quantity" }
        #     }
        #     { $project: _id: 0, point_total: 1 }
        # ]
        # user = Meteor.users.findOne current_order._author_id
        # orders = 
        #     Docs.find 
        #         model:'order'
        #         _author_id:user._id
                
        # total_debits = 0
        # total_calories_consumed = 0
        # for order in orders.fetch() 
        #     if order.purchase_amount
        #         total_debits += parseInt(order.purchase_amount)
        #     product = Docs.findOne _id:order.product_id
        #     if product
        #         if product.calories
        #             total_calories_consumed += parseInt(product.calories)
        # final_calculated_current_points = point_credit_total - total_debits + point_topup_total
        total_sent = 0
        total_sent_hour = 0
        total_sent_day = 0
        
        total_received = 0
        total_received_hour = 0
        total_received_day = 0
        
        now = Date.now()
        hour_gap = 60*60*1000
        hour_ago = now-hour_gap
        # match._timestamp = $gte:hour_ago


        day_gap = 60*60*24*1000
        day_ago = now-day_gap
        # match._timestamp = $gte:day_ago

        
        received_docs = 
            Docs.find
                model:'transfer'
                target_id:user._id
        
        for transfer in received_docs.fetch()
            if transfer.amount
                if transfer._timestamp > hour_ago
                    total_received_hour += transfer.amount 
                if transfer._timestamp > day_ago
                    total_received_day += transfer.amount 
                total_received += transfer.amount 
                
                
        
        sent_docs = 
            Docs.find
                model:'transfer'
                _author_id:user._id
        
        for transfer in sent_docs.fetch()
            if transfer.amount
                if transfer._timestamp > hour_ago
                    total_sent_hour += transfer.amount 
                if transfer._timestamp > day_ago
                    total_sent_day += transfer.amount 
                total_sent += transfer.amount 
        final_calculated_current_points = total_received - total_sent
        
        # if final_calculated_current_points
        #     Meteor.users.update user._id,
        #         $set:
        #             points: final_calculated_current_points
        #     current_point_rank = Meteor.users.find(points:$gt:parseInt(final_calculated_current_points)).count()
        #     Meteor.users.update user._id, 
        #         $set:point_rank:current_point_rank+1

        # calculated_total_earned_credits = point_credit_total
        # calculated_total_bought_credits = point_topup_total

                # 
        received_rank = Meteor.users.find(total_received:$gt:parseInt(total_received)).count()
        sent_rank = Meteor.users.find(total_sent:$gt:parseInt(total_sent)).count()
        # viewed_rank = Meteor.users.find(profile_views:$gt:parseInt(profile_views)).count()
        # Meteor.users.update user._id, 
        #     $set:total_earned_credit_rank:total_earned_credit_rank+1

        
        # calculated_total_credits = point_credit_total + point_topup_total
        
        # if final_calculated_current_points
        Meteor.users.update user._id,
            $set:
                points: final_calculated_current_points
                total_received:total_received
                total_sent:total_sent
                total_sent_hour:total_sent_hour
                total_sent_day:total_sent_day
                total_received:total_received
                total_received_hour:total_received_hour
                total_received_day:total_received_day
                received_rank:received_rank+1
                sent_rank:sent_rank+1
                # total_earned_credits: point_credit_total
                # total_bought_credits: point_topup_total
                # total_credits: point_credit_total + point_topup_total
                # total_calories_consumed: total_calories_consumed
        # amount = Meteor.users.find(points:$gt:parseInt(final_calculated_current_points)).count()
        # Meteor.users.update user._id, 
        #     $set:point_rank:amount


        # res.forEach (tag, i) =>
        #     Meteor.users.update user._id, 
        #         $set:points: tag.point_total
        #     # self.added 'tags', Random.id(),
        #     #     name: tag.name
        #     #     count: tag.count
        #     #     index: i
        
        
    log_view: (doc_id)->
        if Meteor.userId()
            Docs.update doc_id, 
                $addToSet:
                    viewer_ids:Meteor.userId()
                    viewer_usernames:Meteor.user().username
                $inc:views:1
            
        
        
    calc_user_tags: (username)->
        user = Meteor.users.findOne username:username
        Meteor.call 'omega', user._id, 'sent', (err,res)->
        # debit_tags = Meteor.call 'omega', user._id, 'debit', (err, res)->
        
        # Meteor.users.update user._id, 
        #     $set:
        #         sent_tags:sent_tags

        # received_tags = Meteor.call 'omega', user._id, 'received'
        # console.log 'res from async agg', received_tags
        # Meteor.users.update user._id, 
        #     $set:
        #         received_tags:received_tags


    omega: (user_id, direction)->
        user = Meteor.users.findOne user_id
        options = {
            explain:false
            allowDiskUse:true
        }
        match = {}
        match.model = 'transfer'
        if direction is 'sent'
            match._author_id = user_id
        if direction is 'received'
            match.target_id = user_id

        # console.log 'found debits', Docs.find(match).count()
        # if omega.selected_tags.length > 0
        #     limit = 42
        # else
        # limit = 10
        # console.log 'omega_match', match
        # { $match: tags:$all: omega.selected_tags }
        pipe =  [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            # { $match: _id: $nin: omega.selected_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, title: '$_id', count: 1 }
        ]

        if pipe
            # console.log('pipe',pipe)
            agg = global['Docs'].rawCollection().aggregate(pipe,options)
            # else
            # res = {}
            if agg
                # console.log('agg to array', agg)
                agg.toArray()
                # agg.forEach (tag, i) =>
                #     console.log 'for each tag', tag
            #     # printed = console.log(agg.toArray())
            #     agg.toArray()
            #     # omega = Docs.findOne model:'omega_session'
            #     # Docs.update omega._id,
            #     #     $set:
            #     #         agg:agg.toArray()
        else
            return null        
            
            
    complete_transfer: (transfer_id)->
        current_transfer = Docs.findOne transfer_id            
        Docs.update transfer_id, 
            $set:
                status:'purchased'
                purchased:true
                purchase_timestamp: Date.now()
        Meteor.call 'calc_user_points', @_author_id, ->
            
    send_transfer: (transfer_id)->
        transfer = Docs.findOne transfer_id
        target = Meteor.users.findOne transfer.target_id
        transferer = Meteor.users.findOne transfer._author_id

        # Meteor.call 'recalc_one_stats', target._id, ->
        # Meteor.call 'recalc_one_stats', transfer._author_id, ->

        Docs.update transfer_id,
            $set:
                submitted:true
                submitted_timestamp:Date.now()
        return                            
        
        
    set_user_password: (user, password)->
        result = Accounts.setPassword(user._id, password)
        result

    # verify_email: (email)->
    #     (/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(email))


    create_user: (options)->
        Accounts.createUser options

    can_submit: ->
        username = Session.get 'username'
        email = Session.get 'email'
        password = Session.get 'password'
        password2 = Session.get 'password2'
        if username and email
            if password.length > 0 and password is password2
                true
            else
                false


    find_username: (username)->
        res = Accounts.findUserByUsername(username)
        if res
            unless res.disabled
                return res

    new_demo_user: ->
        current_user_count = Meteor.users.find().count()

        options = {
            username:"user#{current_user_count}"
            password:"user#{current_user_count}"
            }

        create = Accounts.createUser options
        new_user = Meteor.users.findOne create
        return new_user
        
        
    