class Cc
  CARDS = {
    '348771682068975'  => { :result => 'approved' },
    '6011739196887563' => { :result => 'approved' },
    '5184778657904478' => { :result => 'approved' },
    '4119862760338320' => { :result => 'approved' },
    '4111111111111111' => { :result => 'approved' },
    '340682458348749'  => { :result => 'declined' },
    '6011191466819647' => { :result => 'declined' },
    '5116381817387388' => { :result => 'declined' },
    '4116196783374209' => { :result => 'declined' },
  }
  def self.result(fullccnum, amount)
    amount.to_s[-2..-1] == '13' ? 'declined' : 'approved'
  end
end
