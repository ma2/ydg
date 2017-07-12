class Room
  attr_reader :book, :box, :calendar, :starting

  BOOK_STATUS = %i(close open_813 open_765 open_119 open_011)
  BOX_STATUS = %i(close test_813 test_765 test_119 test_011)

  def initialize
    @book = :close
    @box = :close
    @calendar = :close
    @starting = true
    @message = 'さあ、どうする？'
  end
end