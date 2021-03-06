class Message < ActiveRecord::Base

  belongs_to :ticket
  belongs_to :user
  
  has_attached_file :attachment,
    :path => ":rails_root/public/uploads/:attachment/:id/:basename.:extension",
    :url => "/uploads/:attachment/:id/:basename.:extension"
  
  
  after_save :send_reply
  after_save :activate_ticket
  # after_post_process :send_reply_with_attachment
  
    
  
  def classes
    klass = self.user ? 'staff_message' : 'customer_message'
  end
  
  protected
  
  def activate_ticket
    self.ticket.activate!
  end
  
  def send_reply
    if self.user
      if self.attachment.file?
        TicketMailer.deliver_ticket_reply_with_attachment(self, self.ticket)
      else 
        TicketMailer.deliver_ticket_reply(self, self.ticket)
      end
    else  
      users = User.find(:all)
      users.each do |u|
        if self.attachment.file?
          TicketMailer.deliver_ticket_update_with_attachment(u, self, self.ticket) if u.categories.include?(self.ticket.category)
        else
          TicketMailer.deliver_ticket_update(u, self, self.ticket) if u.categories.include?(self.ticket.category)
        end
      end
    end
  end
  
  
end
