[1mdiff --git a/.meteor/packages b/.meteor/packages[m
[1mindex b3d4f37..2acb542 100644[m
[1m--- a/.meteor/packages[m
[1m+++ b/.meteor/packages[m
[36m@@ -14,7 +14,6 @@[m [mtracker@1.2.0                 # Meteor's client-side reactive programming librar[m
 random@1.2.0[m
 manuel:reactivearray[m
 meteorhacks:aggregate[m
[31m-babrahams:constellation[m
 mobile-experience@1.1.0[m
 [m
 [m
[1mdiff --git a/.meteor/versions b/.meteor/versions[m
[1mindex 00481be..213bfa6 100644[m
[1m--- a/.meteor/versions[m
[1m+++ b/.meteor/versions[m
[36m@@ -1,14 +1,10 @@[m
 accounts-base@1.9.0[m
 accounts-password@1.7.1[m
 aldeed:simple-schema@1.3.3[m
[31m-aldeed:template-extension@4.1.0[m
 allow-deny@1.1.0[m
 autoupdate@1.7.0[m
 babel-compiler@7.6.2[m
 babel-runtime@1.5.0[m
[31m-babrahams:constellation@0.4.16[m
[31m-babrahams:editable-json@0.6.7[m
[31m-babrahams:temple@0.5.3[m
 base64@1.0.12[m
 binary-heap@1.0.11[m
 blaze@2.5.0[m
[36m@@ -21,15 +17,7 @@[m [mcallback-hook@1.3.0[m
 cfs:http-methods@0.0.32[m
 check@1.3.1[m
 coffeescript@1.0.17[m
[31m-constellation:autopublish@0.4.10[m
[31m-constellation:console@1.4.10[m
[31m-constellation:plugins@0.4.12[m
[31m-constellation:position@0.4.11[m
[31m-constellation:session@0.4.10[m
[31m-constellation:subscriptions@0.4.10[m
[31m-constellation:tiny@0.4.10[m
 dburles:collection-helpers@1.1.0[m
[31m-dburles:mongo-collection-instances@0.3.5[m
 ddp@1.4.0[m
 ddp-client@2.4.1[m
 ddp-common@1.4.0[m
[36m@@ -48,8 +36,6 @@[m [mes5-shim@4.8.0[m
 fetch@0.1.1[m
 francocatena:status@1.5.3[m
 geojson-utils@1.0.10[m
[31m-gwendall:body-events@0.1.7[m
[31m-gwendall:session-json@0.1.7[m
 hot-code-push@1.0.4[m
 html-tools@1.1.2[m
 htmljs@1.1.1[m
[36m@@ -65,7 +51,6 @@[m [miron:middleware-stack@1.1.0[m
 iron:router@1.0.13[m
 iron:url@1.0.11[m
 jquery@1.11.11[m
[31m-lai:collection-extensions@0.2.1_1[m
 launch-screen@1.2.1[m
 lepozepo:cloudinary@4.2.6[m
 less@2.5.7[m
[1mdiff --git a/client/client.coffee b/client/client.coffee[m
[1mindex 6e59712..3ca2b51 100644[m
[1m--- a/client/client.coffee[m
[1m+++ b/client/client.coffee[m
[36m@@ -12,7 +12,15 @@[m [mTemplate.right_sidebar.events[m
     'click .log_out': ->[m
         Meteor.logout()[m
 [m
[32m+[m[32mTemplate.admin_footer.onCreated ->[m
[32m+[m[32m    # @subscribe =>[m[41m [m
[32m+[m[41m    [m
[32m+[m[32mTemplate.admin_footer.helpers[m
[32m+[m[32m    docs: ->[m
[32m+[m[32m        Docs.find()[m
 [m
[32m+[m[32m    users: ->[m
[32m+[m[32m        Meteor.users.find()[m
 [m
 [m
 Router.configure[m
[1mdiff --git a/client/client.jade b/client/client.jade[m
[1mindex 14cd629..3a95695 100644[m
[1m--- a/client/client.jade[m
[1m+++ b/client/client.jade[m
[36m@@ -51,8 +51,24 @@[m [mtemplate(name='layout')[m
                 unless connected[m
                     +status[m
                 +yield[m
[31m-            // if in_role 'admin'[m
[31m-            //     +admin_footer[m
[32m+[m[32m        if in_dev[m
[32m+[m[32m            +admin_footer[m
[32m+[m[41m      [m
[32m+[m[32mtemplate(name='admin_footer')[m
[32m+[m[32m    .ui.fluid.segment[m
[32m+[m[32m        .ui.header[m[41m [m
[32m+[m[32m            i.shield.icon[m
[32m+[m[32m            |admin footer[m
[32m+[m[32m        .ui.header #{docs.count} docs[m
[32m+[m[32m        .ui.header #{users.count} users[m
[32m+[m[32m        .ui.small.list.smallscroll[m
[32m+[m[32m            each docs[m
[32m+[m[32m                .item[m[41m [m
[32m+[m[32m                    .content[m[41m [m
[32m+[m[32m                        .header[m
[32m+[m[32m                            |#{title}[m[41m [m
[32m+[m[32m                        |#{model} #{when} #{_author_username}[m[41m [m
[32m+[m[32m                        .ui.label #{app}[m
       [m
 template(name='nav')[m
     #topnav.ui.fluid.inverted.attached.big.borderless.menu.topnav[m
[1mdiff --git a/client/helpers.coffee b/client/helpers.coffee[m
[1mindex 496b689..ccd86e0 100644[m
[1m--- a/client/helpers.coffee[m
[1m+++ b/client/helpers.coffee[m
[36m@@ -13,6 +13,10 @@[m [mTemplate.registerHelper 'included_ingredients', () ->[m
         model:'ingredient'[m
         _id: $in:@ingredient_ids[m
 [m
[32m+[m[32mTemplate.registerHelper 'is_current_user', () ->[m
[32m+[m[32m    Meteor.user().username is Router.current().params.username[m
[32m+[m
[32m+[m
 Template.registerHelper 'ingredient_products', () ->[m
     Docs.find   [m
         model:'product'[m
[1mdiff --git a/client/orders.jade b/client/orders.jade[m
[1mindex e45bcb9..77ffa8e 100644[m
[1m--- a/client/orders.jade[m
[1m+++ b/client/orders.jade[m
[36m@@ -34,14 +34,14 @@[m
 //                             +order_item[m
 //                             .ui.divider[m
 template(name='orders')[m
[31m-    .ui.stackable.grid[m
[32m+[m[32m    .ui.stackable.padded.grid[m
         .sixteen.wide.column[m
             .ui.header [m
                 i.money.icon[m
                 |orders[m
             .ui.list[m
                 each order_docs[m
[31m-                    .item #{title}[m
[32m+[m[32m                    .item #{title} #{when} #{_author_username}[m
             [m
             [m
                         [m
[1mdiff --git a/lib/home.coffee b/lib/home.coffee[m
[1mindex c4ac603..8216609 100644[m
[1m--- a/lib/home.coffee[m
[1m+++ b/lib/home.coffee[m
[36m@@ -20,8 +20,6 @@[m [mif Meteor.isClient[m
                 section:'soup'[m
                 soup_of_the_day:true[m
             [m
[31m-    Template.orders.onCreated ->[m
[31m-        @autorun => @subscribe 'model_docs', 'order', ->[m
     Template.losses.onCreated ->[m
         @autorun => @subscribe 'model_docs', 'loss', ->[m
     Template.losses.helpers[m
[1mdiff --git a/lib/order.coffee b/lib/order.coffee[m
[1mindex 91d0abb..eb49013 100644[m
[1m--- a/lib/order.coffee[m
[1m+++ b/lib/order.coffee[m
[36m@@ -10,8 +10,8 @@[m [mif Meteor.isClient[m
         # @autorun -> Meteor.subscribe 'model_docs', 'thing', 100[m
 [m
     Template.orders.helpers[m
[31m-        orders: ->[m
[31m-            match = {model:'order'}[m
[32m+[m[32m        order_docs: ->[m
[32m+[m[32m            match = {model:'order', app:'bc'}[m
             if Session.get('order_status_filter')[m
                 match.status = Session.get('order_status_filter')[m
             if Session.get('order_delivery_filter')[m
[36m@@ -141,9 +141,9 @@[m [mif Meteor.isClient[m
 if Meteor.isServer[m
     Meteor.publish 'orders', (order_id, status)->[m
         # order = Docs.findOne order_id[m
[31m-        match = {model:'order'}[m
[31m-        if status [m
[31m-            match.status = status[m
[32m+[m[32m        match = {model:'order', app:'bc'}[m
[32m+[m[32m        # if status[m[41m [m
[32m+[m[32m        #     match.status = status[m
 [m
         Docs.find match[m
         [m
[1mdiff --git a/lib/profile.jade b/lib/profile.jade[m
[1mindex f16157c..9dfea4b 100644[m
[1m--- a/lib/profile.jade[m
[1m+++ b/lib/profile.jade[m
[36m@@ -133,12 +133,15 @@[m [mtemplate(name='user_dashboard')[m
             .column[m
                 .ui.header #{points} points[m
                 .ui.inline.header [m
[31m-                    i.shield.icon[m
[32m+[m[32m                    +i name='shield'[m
                     |roles[m
                 each roles[m
                     .ui.label #{this}[m
[31m-                .ui.header roles #{role}[m
[31m-                .ui.header badges #{role}[m
[32m+[m[32m                .ui.header[m[41m [m
[32m+[m[32m                    +i name='certificate'[m
[32m+[m[32m                    |badges[m
[32m+[m[32m                each user_badges[m
[32m+[m[32m                    .ui.label #{this}[m
                 [m
             .column[m
                 unless is_current_user[m
[36m@@ -155,6 +158,12 @@[m [mtemplate(name='user_dashboard')[m
             [m
     [m
     [m
[32m+[m[32mtemplate(name='user_sent')[m
[32m+[m[32m    .ui.header user sent[m
[32m+[m[32m    each point_transfers[m
[32m+[m[32m        .ui.header #{when}[m
[32m+[m[41m    [m
[32m+[m[41m    [m
 template(name='friend_button')[m
     if is_friend[m
         .ui.blue.button.unfriend[m
[1mdiff --git a/lib/user_edit.jade b/lib/user_edit.jade[m
[1mindex 49425ba..3c9be09 100644[m
[1m--- a/lib/user_edit.jade[m
[1m+++ b/lib/user_edit.jade[m
[36m@@ -1,7 +1,7 @@[m
 template(name='user_edit')[m
     with current_user          [m
         //- img.ui.fluid.image.checkin_banner(src="{{c.url banner_image_id width=1000 height=500 crop='crop'}}")    [m
[31m-        .ui.stackable.grid[m
[32m+[m[32m        .ui.stackable.padded.grid[m
             .row[m
                 .four.wide.column[m
                     .ui.center.aligned.large.inline.grey.header[m
