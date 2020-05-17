;;; config.el --- -*- lexical-binding: t -*-

(setq user-full-name "Jay Nguyen"
      user-mail-address "iam.nguyen@pm.me")

(setq doom-font (font-spec :family "Fira Code" :size 12)
      doom-big-font (font-spec :family "Merriweather" :size 18)
      doom-variable-pitch-font (font-spec :family "InputMono" :size 14 :height 120))
      doom-unicode-font (font-spec :family "all-the-icons")

;; load theme
(setq doom-theme 'doom-vibrant)

(custom-set-faces!
  '(doom-modeline-buffer-modified :foreground "orange"))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

(setq garden-directory "~/Projects/iamNguyen/contents")

(setq org-directory "~/Projects/org")

(setq-default
 delete-by-moving-to-trash t                      ; Delete files to trash
 tab-width 4                                      ; Set width for tabs
 uniquify-buffer-name-style 'forward              ; Uniquify buffer names
 window-combination-resize t                      ; take new window space from all other windows (not just current)
 x-stretch-cursor t)                              ; Stretch cursor to the glyph width

(setq undo-limit 80000000                         ; Raise undo-limit to 80Mb
      evil-want-fine-undo t                       ; By default while in insert all changes are one big blob. Be more granular
      auto-save-default t                         ; Nobody likes to loose work, I certainly don't
      inhibit-compacting-font-caches t)           ; When there are lots of glyphs, keep them in memory

(delete-selection-mode 1)                         ; Replace selection when inserting text
(display-time-mode 1)                             ; Enable time in the mode-line
(display-battery-mode 1)                          ; On laptops it's nice to know how much power you have
(global-subword-mode 1)                           ; Iterate through CamelCase words

(use-package deft
  :bind ("C-c d" . deft)
  :commands (deft)
  :config (setq deft-directory (concat org-directory "/notes")
                deft-extensions '("md" "org") ;; md as default file
                deft-recursive t   ;;search files in subdirectories
                deft-use-filename-as-title t ;; title is same as filename
  ))

(use-package org-tempo)
(add-to-list 'org-structure-template-alist '("m" . "src emacs-lisp"))
(add-to-list 'org-structure-template-alist
             '("y" . "src yaml
---
title:
date:
excerpt:
tags:
---"))


(add-to-list 'org-structure-template-alist
             '("x" . "src x
#+TITLE:
#+EXPORT_FILE_NAME:
#+OPTIONS: toc:nil
#+begin_src yaml
---
title:
date:
excerpt:
tags:
---
#+end yaml"))

(after! org (setq org-todo-keywords
      '((sequence  ;;for org-capture mainly for todo list
         "TODO(t)"
         "ACTIVE(a)"
         "SOMEDAY(s!)"
         "DELEGATED(e!)"
         "DONE(d!)"))))

(after! org (setq org-todo-keyword-faces
      '(("TODO" :foreground "OrangeRed" :weight bold)
        ("ACTIVE" :foreground "DeepPink" :weight bold)
        ("SOMEDAY" :foreground "gold" :weight bold)
        ("DELEGATED" :foreground "spring green" :weight bold)
        ("DONE" :foreground "slategrey" :weight bold :strike-through t))))

(setq +org-capture-todo (concat org-directory "/workload/inbox.org"))
(after! org-capture
  ;;<<prettify-capture>>
  (add-transient-hook! 'org-capture-select-template
    (setq org-capture-templates
          (doct `(
                ;;
                ;; Inbox capture
                ;;
                  (,(format "%s\tInbox" (all-the-icons-octicon "inbox" :face 'all-the-icons-yellow :v-adjust 0.01))
                   :keys "k"
                   :file +org-capture-todo
                   :prepend t
                   :headline "INBOX"
                   :type entry
                   :template ("* TODO %? %^G%{extra}"
                              "%i")
                   :children ((,(format "%s\tGeneral Task" (all-the-icons-octicon "inbox" :face 'all-the-icons-lmaroon :v-adjust 0.01))
                               :keys "k"
                               :extra ""
                               )
                              (,(format "%s\tTask with Deadline" (all-the-icons-material "timer" :face 'all-the-icons-dmaroon :v-adjust -0.1))
                               :keys "d"
                               :extra "\nDEADLINE: %^{Deadline:}t"
                               )
                              (,(format "%s\tScheduled Task" (all-the-icons-octicon "calendar" :face 'all-the-icons-maroon :v-adjust 0.01))
                               :keys "s"
                               :extra "\nSCHEDULED: %^{Start time:}t"
                               )
                              ))
                ;;
                ;; Interesting capture
                ;;
                  (,(format "%s\tInteresting" (all-the-icons-octicon "light-bulb" :face 'all-the-icons-lcyan :v-adjust 0.01))
                   :keys "i"
                   :file +org-capture-todo
                   :prepend t
                   :headline "INTERESTING"
                   :type entry
                   :template ("* [ ] %{desc}%? :%{i-type}:"
                                "%i %a")
                   :children ((,(format "%s\tWebpage" (all-the-icons-octicon "browser" :face 'all-the-icons-green :v-adjust 0.01))
                               :keys "w"
                               :desc "%(org-cliplink-capture) "
                               :i-type "read:web"
                               )
                              (,(format "%s\tArticle" (all-the-icons-octicon "file-text" :face 'all-the-icons-yellow :v-adjust 0.01))
                               :keys "a"
                               :desc ""
                               :i-type "read:research"
                               )
                              (,(format "%s\tInformation" (all-the-icons-faicon "info-circle" :face 'all-the-icons-blue :v-adjust 0.01))
                               :keys "i"
                               :desc ""
                               :i-type "read:info"
                               )
                              (,(format "%s\tIdea" (all-the-icons-material "bubble_chart" :face 'all-the-icons-silver :v-adjust 0.01))
                               :keys "I"
                               :desc ""
                               :i-type "idea"
                               )))
)))))

(after! org (setq org-agenda-files (concat org-directory "/workload/inbox.org")))

(setq org-agenda-custom-commands
      '(("k" "Tasks - work on it!"
         ((agenda ""
                  ((org-agenda-overriding-header "Agenda \nWhere things have a scheduled and deadlined.\n\n")
                   (org-agenda-span 'day)
                   (org-agenda-start-day (org-today))
                   (org-agenda-files '("~/Projects/org/workload/inbox.org"))))
          (todo ""
                ((org-agenda-overriding-header "Tasks")
                 (org-agenda-skip-function
                  '(or
                    (and
                     (org-agenda-skip-entry-if 'notregexp "#[A-C]")
                     (org-agenda-skip-entry-if 'notregexp ":@\\w+"))
                    (org-agenda-skip-if nil '(scheduled deadline))
                    (org-agenda-skip-if 'todo '("SOMEDAY"))
                 ))
                 (org-agenda-files '("~/Projects/org/workload/inbox.org"))
                 (org-super-agenda-groups
                  '((:name "Priority Items"
                           :priority>= "B")
                    (:auto-parent t)))))
          (todo ""
                ((org-agenda-overriding-header "Delegated Tasks")
                 (org-agenda-files '("~/Projects/org/workload/inbox.org"))
                 (org-tags-match-list-sublevels t)
                 (org-agenda-skip-function
                  '(or
                    (org-agenda-skip-subtree-if 'nottodo '("DELEGATED"))))
                 (org-super-agenda-groups
                  '((:auto-property "WHO")))))))
        ("i" "Inbox - tasks really to sort"
         ((todo ""
                ((org-agenda-overriding-header "Inbox \nWhere everything is collected.\nContains TODO and ACTIVE without deadlines and schedules.\n\n ")
                 (org-agenda-skip-function
                  '(or
                    (org-agenda-skip-entry-if 'regexp ":@\\w+")
                    (org-agenda-skip-entry-if 'regexp "\[#[A-E]\]")
                    (org-agenda-skip-if 'nil '(scheduled deadline))
                    (org-agenda-skip-entry-if 'todo '("SOMEDAY"))
                    (org-agenda-skip-entry-if 'todo '("DELEGATED"))))
                 (org-agenda-files '("~/Projects/org/workload/inbox.org"))
                 (org-super-agenda-groups
                  '((:auto-ts t)))))))
        ("s" "Someday - tasks without specific date"
         ((todo ""
                ((org-agenda-overriding-header "Someday \nWhere things you don't want to do now but it might be useful in the future.\nContains only tasks with SOMEDAY keyword inc w/wo deadlined or scheduled.\n\n")
                 (org-agenda-skip-function
                  '(or
                    (org-agenda-skip-entry-if 'nottodo '("SOMEDAY"))))
                 (org-agenda-files '("~/Projects/org/workload/inbox.org"))
                 (org-super-agenda-groups
                  '((:auto-parent t)))))))
        ("n" "Notes - contains everything"
         ((todo ""
                ((org-agenda-overriding-header "Note Actions \nContains everything and anything in the inbox.\n\n")
                 (org-agenda-files '("~/Projects/org/workload/inbox.org"))
                 (org-super-agenda-groups
                  '((:auto-category t)))))))

))

(use-package! org-roam
  :commands (org-roam-insert org-roam-find-file org-roam)
  :init
  (setq org-roam-directory (concat org-directory "/notes/"))
  (setq org-roam-graph-viewer (concat org-directory "/notes/"))
  :bind (:map org-roam-mode-map
          (("C-c n l" . org-roam)
           ("C-c n f" . org-roam-find-file)
           ("C-c n g" . org-roam-graph-show)
           ("C-c n b" . org-roam-switch-to-buffer))
          :map org-mode-map
          (("C-c n i" . org-roam-insert)))
  :config
  (org-roam-mode +1))
(require 'company-org-roam)
(push 'company-org-roam company-backends)
