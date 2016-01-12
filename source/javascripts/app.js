// Fix hamburger display for back button
var spinner = $('#spinner-form');

if (spinner.is(':checked')) {
  spinner.prop('checked', false);
}

// Toggle mennu
$('#menu-toggle').click(function() {
  $('#desktop-collapse').toggleClass('open');

  spinner.attr('aria_expanded', function (i, attr) {
    return attr === 'true' ? 'false' : 'true'
  });
});
