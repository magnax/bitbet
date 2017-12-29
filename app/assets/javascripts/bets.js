$(function() {
  $('.my_bets span').click(function() {
    $(this).parent().find('.my_bets_list').toggle('slow');
  }); 
});
