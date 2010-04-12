import os
from datetime import *
from google.appengine.ext import db
from google.appengine.ext import webapp
from google.appengine.ext.webapp import util
from google.appengine.ext.webapp import template

class Group(db.Model):
	nickname = db.StringProperty()
	created = db.DateTimeProperty(auto_now_add=True)
	members = db.IntegerProperty()
	
class Guest(db.Model):
	created = db.DateTimeProperty(auto_now_add=True)
	updated = db.DateTimeProperty(auto_now_add=True)
	group = db.ReferenceProperty(Group, collection_name='guests')
	nickname = db.StringProperty()

class GroupHandler(webapp.RequestHandler):
	
	def get(self, group_id=None):
		now = datetime.now()
		later = datetime.now() + timedelta(seconds=15)
		if(group_id):
			ext = "html"
			mimetype = self.request.get('mimetype')
			if(mimetype):
				ext = mimetype
				
			output_template = "view."+ext
			group = Group.get(group_id)
			guests = group.guests.filter("updated >", datetime.now() - timedelta(seconds=15)).order("-updated")[0:7]
			old_guests = group.guests.filter("updated <", datetime.now() - timedelta(seconds=15)).order("-updated")[0:7]
			template_values = {'group': group,
							   'guests':guests,
							   'old_guests':old_guests,
							   'now': now,
							   'later':later}
			path = os.path.join(os.path.dirname(__file__), output_template)
			self.response.out.write(template.render(path, template_values))
			
		else:
			ext = 'html'
			mimetype = self.request.get('mimetype')
			if(mimetype):
				ext = mimetype
			output_template = "index."+ext
			groups = Group.all()
			
			template_values = {'groups': groups}
			path = os.path.join(os.path.dirname(__file__), output_template)
			self.response.out.write(template.render(path, template_values))	
		
	def post(self):
		group = Group()
		group.nickname = self.request.get("nickname")
		group.members = 0
		group.put()
		self.redirect("/")
		
	def delete(self, group_id):
		group = Group().get(group_id)
		group.delete()
	
		
class GuestHandler(webapp.RequestHandler):
	def get(self, group_id):
		group = Group.get(group_id)
		guest = Guest()
		guest.nickname = self.request.get('nickname')
		guest.group = group
		guest.put()
		
		ext = "html"
		mimetype = self.request.get('mimetype')
		if(mimetype):
			ext = mimetype
		output_template = "guest." + ext
		
		template_values = {'guest': guest}
		path = os.path.join(os.path.dirname(__file__), output_template)
		self.response.out.write(template.render(path, template_values))
	
	def post(self, group_id):
		group = Group.get(group_id)
		guest = Guest()
		guest.nickname = self.request.get('nickname')
		guest.group = group
		guest.put()
		self.redirect('/group/'+str(group.key())+'/')
		
	def put(self, guest_id):
		guest = Guest.get(guest_id)
		guest.updated = datetime.now()
		guest.put()
		
	def delete(self, guest_id):
		guest = Guest().get(guest_id)
		guest.delete()

class StatusHandler(webapp.RequestHandler):
	def get(self, guest_id):
		guest = Guest.get(guest_id)
		guest.updated = datetime.now()
		guest.put()
		
		ext = "html"
		mimetype = self.request.get('mimetype')
		if(mimetype):
			ext = mimetype
		output_template = "guest." + ext
		
		template_values = {'guest': guest}
		path = os.path.join(os.path.dirname(__file__), output_template)
		self.response.out.write(template.render(path, template_values))
		
class Index(webapp.RequestHandler):
	def get(self):
		self.redirect('/group/')

def main():
	application = webapp.WSGIApplication([('/', Index),
										  ('/group/(.*?)/', GroupHandler),
										  ('/group/', GroupHandler), 
										  ('/guest/(.*?)/', GuestHandler),
										  ('/guest/', GuestHandler),
										  ('/status/guest/(.*?)/', StatusHandler)],
                                       	  debug=True)
	util.run_wsgi_app(application)


if __name__ == '__main__':
  main()
