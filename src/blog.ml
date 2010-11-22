open Printf

type ent = {
  updated: int * int * int * int * int; (* year,month,day,hour,min *)
  author: Atom.author;
  subject: string;
  category: (string * string) list; (* category, subcategory, see list of them below *)
  body: string;
  permalink: string;
}

let anil = { Atom.name="Anil Madhavapeddy"; uri=Some "http://anil.recoil.org"; email=Some "anil@recoil.org" }
let thomas = { Atom.name="Thomas Gazagnaire"; uri=Some "http://gazagnaire.org"; email=Some "thomas.gazagnaire@gmail.com" }
let rights = Some "All rights reserved by the author"

let categories = [
  "overview", [
      "website"; "usage"; "papers"
  ];
  "language", [
      "syntax"; "dyntype"
  ];
  "backend", [
      "unix"; "xen"; "browser"; "arm"; "mips"
  ];
  "network", [
      "ethernet"; "dhcp"; "arp"; "tcpip"; "dns"; "http"; "typeropes"
  ];
  "storage", [
      "block"; "files"; "orm"
  ];
  "concurrency", [
      "threads"; "processes"
  ];
]

let entries = [
  { updated=2010,11,13,18,10;
    author=anil;
    subject="Developing the Mirage networking stack on UNIX";
    body="net-unix.md";
    permalink="running-ethernet-stack-on-unix";
    category=["overview","usage"; "backend","unix"];
  };

  { updated=2010,11,10,11,0;
    author=anil;
    subject="Source code layout";
    body="repo-layout.md";
    permalink="source-code-layout";
    category=["overview","usage"];
  };
  { 
    updated=2010,11,4,16,30;
    author=thomas;
    subject="A (quick) introduction to HTCaML";
    category=["language","syntax"];
    body="htcaml-part1.md";
    permalink="introduction-to-htcaml";
  };
  { updated=2010,10,11,15,0;
    author=anil;
    subject="Self-hosting Mirage website";
    body="blog-welcome.md";
    permalink="self-hosting-mirage-website";
    category=["overview","website"];
  };
]

let cmp_entry a b =
  let cmp_up (yr1,mn1,da1,_,_) (yr2,mn2,da2,_,_) =
    match yr1 - yr2 with
    | 0 ->
       (match mn1 - mn2 with
        | 0 -> da1 - da2
        | n -> n
       )
    | n -> n in
  cmp_up a.updated b.updated

let entries = List.rev (List.sort cmp_entry entries)
let _ = List.iter (fun x -> Printf.printf "ENT: %s\n%!" x.subject) entries

let num_l1_categories l1 =
  List.fold_left (fun a e ->
    List.fold_left (fun a (l1',_) ->
      if l1' = l1 then a+1 else a
    ) 0 e.category + a
  ) 0 entries

let num_l2_categories l1 l2 =
  List.fold_left (fun a e ->
    List.fold_left (fun a (l1',l2') ->
      if l1'=l1 && l2'=l2 then a+1 else a
    ) 0 e.category + a
  ) 0 entries

let permalink e =
  sprintf "%s/blog/%s" Config.baseurl e.permalink

let permalink_exists x = List.exists (fun e -> e.permalink = x) entries

let atom_entry_of_ent filefn e =
  let meta = { Atom.id=permalink e; title=`Text e.subject;
    subtitle=`Empty; author=Some e.author; contributors=[];
    updated=e.updated; rights } in
  let content = `XML (filefn e.body) in
  { Atom.entry=meta; summary=`Empty; content }
  
let atom_feed filefn es = 
  let es = List.rev (List.sort cmp_entry es) in
  let updated = (List.hd es).updated in
  let id = sprintf "%s/blog/" Config.baseurl in
  let title = `Text "openmirage blog" in
  let subtitle = `Text "a cloud operating system" in
  let author = Some anil in
  let contributors = [ anil; thomas ] in
  let feed = { Atom.id; title; subtitle; author; contributors; rights; updated } in
  let entries = List.map (atom_entry_of_ent filefn) es in
  { Atom.feed=feed; entries }

