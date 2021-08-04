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

    calc_user_points: (username)->
        user = Meteor.users.findOne username:username
        match = {}
        match._author_username = username
       
       
        match.model = 'work'
        match.task_points = $exists:true
        point_credit_total = 0
        
        
        point_credit_docs = Docs.find(match).fetch()
        for point_doc in point_credit_docs 
            point_credit_total += point_doc.task_points
            
        # console.log 'work credit total', point_credit_total
        
        topup_match = {}
        topup_match.model = 'topup'
        topup_match.topup_amount = $exists:true
        point_topup_total = 0
        
        point_topup_docs = Docs.find(topup_match).fetch()
        for topup_doc in point_topup_docs 
            # console.log topup_doc.topup_amount
            if topup_doc.topup_amount
                point_topup_total += parseInt(topup_doc.topup_amount)
            
        # console.log 'topup credit total', point_topup_total
                        # 
        total_bought_credit_rank = Meteor.users.find(total_bought_credits:$gt:parseInt(point_topup_total)).count()
        # console.log 'total earned credit rank', total_earned_credit_rank
        Meteor.users.update user._id, 
            $set:total_bought_credit_rank:total_bought_credit_rank+1

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
        orders = 
            Docs.find 
                model:'order'
                _author_id:user._id
                
        total_debits = 0
        total_calories_consumed = 0
        for order in orders.fetch() 
            # console.log 'order purchase amount', order.purchase_amount
            if order.purchase_amount
                total_debits += parseInt(order.purchase_amount)
            product = Docs.findOne _id:order.product_id
            if product
                if product.calories
                    console.log 'calories added', product.calories
                    total_calories_consumed += parseInt(product.calories)
        # console.log 'total debits', total_debits
        # console.log 'total credits', point_credit_total
        final_calculated_current_points = point_credit_total - total_debits + point_topup_total
        
        
        # console.log 'total current points', final_calculated_current_points
        if final_calculated_current_points
            Meteor.users.update user._id,
                $set:
                    points: final_calculated_current_points
            current_point_rank = Meteor.users.find(points:$gt:parseInt(final_calculated_current_points)).count()
            # console.log 'amount more ranked', current_point_rank
            Meteor.users.update user._id, 
                $set:point_rank:current_point_rank+1

        calculated_total_earned_credits = point_credit_total
        calculated_total_bought_credits = point_topup_total

                # 
        total_earned_credit_rank = Meteor.users.find(total_earned_credits:$gt:parseInt(calculated_total_earned_credits)).count()
        # console.log 'total earned credit rank', total_earned_credit_rank
        Meteor.users.update user._id, 
            $set:total_earned_credit_rank:total_earned_credit_rank+1

        
        calculated_total_credits = point_credit_total + point_topup_total
        
        # console.log 'total current points', final_calculated_current_points
        if final_calculated_current_points
            Meteor.users.update user._id,
                $set:
                    points: final_calculated_current_points
                    total_earned_credits: point_credit_total
                    total_bought_credits: point_topup_total
                    total_credits: point_credit_total + point_topup_total
                    total_calories_consumed: total_calories_consumed
            amount = Meteor.users.find(points:$gt:parseInt(final_calculated_current_points)).count()
            console.log 'amount more ranked', amount
            Meteor.users.update user._id, 
                $set:point_rank:amount


        # res.forEach (tag, i) =>
        #     console.log tag
        #     Meteor.users.update user._id, 
        #         $set:points: tag.point_total
        #     # self.added 'tags', Random.id(),
        #     #     name: tag.name
        #     #     count: tag.count
        #     #     index: i


            