class Contact < ActiveRecord::Base
  has_many :purchase_orders
  has_many :purchase_invoices
  has_many :sales_orders
  has_many :sales_invoices
  has_many :delivery_orders
  has_many :purchase_receivals 
  
  def self.create_object(params)
    new_object = self.new 
    new_object.name             = params[:name    ]         
    new_object.description      = params[:description      ]
    new_object.address          = params[:address          ]
    new_object.shipping_address = params[:shipping_address ]
    new_object.save 
    return new_object 
  end
  
  def update_object( params ) 
    self.name             =  params[:name    ]         
    self.description      =  params[:description      ]
    self.address          =  params[:address          ]
    self.shipping_address =  params[:shipping_address ]
    self.save
    
    return self 
  end
  
  def delete_object
    if self.purchase_orders.count? or
        self.purchase_invoices.count? or
        self.sales_orders.count? or
        self.sales_invoices.count? or
        self.delivery_orders.count? or 
        self.purchase_receivals.count? 
      self.errors.add(:generic_errors, "Sudah ada transaksi")
      return self 
    end
    
    self.desroy 
  end
   
  
  
  
  def active_objects
    self.where(:is_deleted => false )
  end
end
