require 'rails_helper'
require 'time_util'

include TimeUtil

RSpec.describe User, :type => :model do
  fixtures :all
  describe '#my_hand' do
    context '存在しないjid=201707010000' do
      let(:jid) { '201707010000' }
      it 'u01の手がnilであること' do
        user = users(:u01)
        expect(user.my_hand(jid)).not_to be
      end
      it 'u02の手がnilであること' do
        user = users(:u02)
        expect(user.my_hand(jid)).not_to be
      end
    end
    context 'jid=201708101200' do
      let(:jid) { '201708101200' }
      it 'u01の手がグー（0）であること' do
        user = users(:u01)
        expect(user.my_hand(jid)).to eq 0
      end
      it 'u02の手がチョキ（1）であること' do
        user = users(:u02)
        expect(user.my_hand(jid)).to eq 1
      end
      it '参加していないu03の手はnilであること' do
        user = users(:u03)
        expect(user.my_hand(jid)).not_to be
      end
    end
  end
  describe '#do_janken' do
    context 'jid=201708101200' do
      before do
        Timecop.freeze(Time.local(2017, 8, 10, 12, 5))
      end
      it 'u01はnilが返ること' do
        user = users(:u01)
        expect(user.do_janken(1)).not_to be
      end
      it 'u02はnilが返ること' do
        user = users(:u02)
        expect(user.do_janken(1)).not_to be
      end
      it 'u03はtrueが返ること' do
        user = users(:u03)
        expect(user.do_janken(1)).to be
        expect(user.my_hand(current_jid)).to eq 1
      end
    end
    context 'jid=201708151200' do
      before do
        Timecop.freeze(Time.local(2017, 8, 15, 12, 5))
      end
      it 'u01はtrueが返ること' do
        user = users(:u01)
        expect(user.do_janken(0)).to be
        expect(user.my_hand(current_jid)).to eq 0
      end
      it 'u02はtrueが返ること' do
        user = users(:u02)
        expect(user.do_janken(1)).to be
        expect(user.my_hand(current_jid)).to eq 1
      end
      it 'u03はtrueが返ること。二度目はfalseが返ること' do
        user = users(:u03)
        expect(user.do_janken(2)).to be
        expect(user.my_hand(current_jid)).to eq 2
        expect(user.do_janken(2)).not_to be
      end
    end
  end
  describe '#set_result' do
    context 'jid=201708101200（ぐー（0）の勝利）' do
      let(:janken) { jankens(:jk01) }
      it 'u01は勝利してq3が1増えること' do
        user = users(:u01)
        v = janken.victory
        expect { user.set_result(v, janken.jid) }.to change { user.q3 }.by(1)
        expect { user.set_result(v, janken.jid) }.not_to change { user.q4 }
        expect { user.set_result(v, janken.jid) }.not_to change { user.q5 }
      end
      it 'u02は敗北してq4が1増えること' do
        user = users(:u02)
        v = janken.victory
        expect { user.set_result(v, janken.jid) }.not_to change { user.q3 }
        expect { user.set_result(v, janken.jid) }.to change { user.q4 }.by(1)
        expect { user.set_result(v, janken.jid) }.not_to change { user.q5 }
      end
      it 'u03は参加していないので変化しないこと' do
        user = users(:u03)
        v = janken.victory
        expect { user.set_result(v, janken.jid) }.not_to change { user.q3 }
        expect { user.set_result(v, janken.jid) }.not_to change { user.q4 }
        expect { user.set_result(v, janken.jid) }.not_to change { user.q5 }
      end
    end
    context 'jid=201708152200（あいこ（-1））' do
      let(:janken) { jankens(:jk05) }
      it 'u01はあいこでq5が1増えること' do
        user = users(:u01)
        v = janken.victory
        expect { user.set_result(v, janken.jid) }.not_to change { user.q3 }
        expect { user.set_result(v, janken.jid) }.not_to change { user.q4 }
        expect { user.set_result(v, janken.jid) }.to change { user.q5 }
      end
      it 'u02はあいこでq5が1増えること' do
        user = users(:u02)
        v = janken.victory
        expect { user.set_result(v, janken.jid) }.not_to change { user.q3 }
        expect { user.set_result(v, janken.jid) }.not_to change { user.q4 }
        expect { user.set_result(v, janken.jid) }.to change { user.q5 }.by(1)
      end
      it 'u03は参加していないので変化しないこと' do
        user = users(:u03)
        v = janken.victory
        expect { user.set_result(v, janken.jid) }.not_to change { user.q3 }
        expect { user.set_result(v, janken.jid) }.not_to change { user.q4 }
        expect { user.set_result(v, janken.jid) }.not_to change { user.q5 }
      end
    end
  end
end
