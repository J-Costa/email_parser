module NavigationHelper
  def active_tab(*paths, **opts)
    active = paths.any? { |path| current_page?(path) }
    classes = [ "nav-link" ]
    classes << "active" if active
    classes.join(" ")
  end
end
