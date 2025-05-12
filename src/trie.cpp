#include <algorithm>
#include <cstddef>
#include <future>
#include <map>
#include <memory>
#include <optional>
#include <stdexcept>
#include <string>
#include <unordered_map>
#include <utility>
#include <vector>

namespace moo {
class TrieNode {
 public:
  TrieNode() = default;

  explicit TrieNode(std::map<char, std::shared_ptr<const TrieNode>> children) : children_(std::move(children)) {}

  virtual ~TrieNode() = default;

  virtual auto Clone() const -> std::unique_ptr<TrieNode> { return std::make_unique<TrieNode>(children_); }


  std::map<char, std::shared_ptr<const TrieNode>> children_;

  bool is_value_node_{false};
};

template <class T>
class TrieNodeWithValue : public TrieNode {
 public:
  explicit TrieNodeWithValue(std::shared_ptr<T> value) : value_(std::move(value)) { this->is_value_node_ = true; }

  TrieNodeWithValue(std::map<char, std::shared_ptr<const TrieNode>> children, std::shared_ptr<T> value)
      : TrieNode(std::move(children)), value_(std::move(value)) {
    this->is_value_node_ = true;
  }

  auto Clone() const -> std::unique_ptr<TrieNode> override {
    return std::make_unique<TrieNodeWithValue<T>>(children_, value_);
  }

  std::shared_ptr<T> value_;
};


class Trie {
 private:
  std::shared_ptr<const TrieNode> root_{nullptr};

  explicit Trie(std::shared_ptr<const TrieNode> root) : root_(std::move(root)) {}

 public:
  Trie() = default;

  template <class T> auto find(std::string_view key);

  template <class T> auto insert(std::string_view key, T value);

  auto remove(std::string_view key);

  auto get_root() const -> std::shared_ptr<const TrieNode> { return root_; }
};
}
