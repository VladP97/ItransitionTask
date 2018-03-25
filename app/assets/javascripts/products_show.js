$(document).ready(function () {
    $('.radio').change(function () {
        console.log($("#chart-container").data("period"));
        $("#chart-container").data("period", $(this).data("period"));
        $.ajax({
            type: "get",
            url: "/products/" + window.location.pathname.split('/')[2] + "/show_chart",
            data: {
              period: $(this).data("period")
            },
            success: function (response) {
                $("#chart-container").replaceWith(response);
            }
        });
    });
});