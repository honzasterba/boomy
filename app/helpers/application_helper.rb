# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def errors_for(obj)
    return if obj.nil? or !obj.respond_to?(:errors)
    render :partial => "/shared/errors", :locals => { :object => obj } 
  end
  
  def smiley
    arr = [";-)", "8-)", ":-D", ":-O", ":-]", ":-}"]
    arr[rand(arr.size)]
  end
  
  def gimme_more
    arr = ["Já chcu víc!", "Další, prosím!", "Ještě! Ještě!", "Více zábavy!" ]
    arr[rand(arr.size)]
  end
  
end
