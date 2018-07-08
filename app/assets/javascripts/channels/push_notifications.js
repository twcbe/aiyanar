(function () {
    App.push_notifications = App.cable.subscriptions.create("PushNotificationsChannel", {
        connected: function () {
            console.log('connected called');
        },
        disconnected: function () {
            console.log('disconnected called');
        },
        received: function (data) {
            if(window.location.pathname.includes('cards/new')) {
                $('#card_card_number').val(data.card_number);
            }
            console.log('received called with ', data);
        },
        notify: function () {
            console.log('notify called');
            return this.perform('notify');
        }
    });
}).call(this);
